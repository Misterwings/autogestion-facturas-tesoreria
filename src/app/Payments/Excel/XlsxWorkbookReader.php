<?php

namespace App\Payments\Excel;

use App\Payments\Contracts\ExcelWorkbookReaderInterface;
use App\Payments\DTO\SpreadsheetRow;
use Generator;
use RuntimeException;
use SimpleXMLElement;
use XMLReader;
use ZipArchive;

class XlsxWorkbookReader implements ExcelWorkbookReaderInterface
{
    private const MAX_ENTRIES = 1000;

    private const MAX_UNCOMPRESSED_BYTES = 104857600;

    private const MAX_ENTRY_BYTES = 52428800;

    private const MAX_COMPRESSION_RATIO = 200;

    private const SPREADSHEET_NS = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';

    private const RELATIONSHIP_NS = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';

    private const PACKAGE_RELATIONSHIP_NS = 'http://schemas.openxmlformats.org/package/2006/relationships';

    /** @var array<string, string> */
    private array $sheetPaths = [];

    /** @var list<string> */
    private array $sharedStrings = [];

    public function __construct(private readonly string $path)
    {
        if (! is_file($path)) {
            throw new RuntimeException("Workbook not found: {$path}");
        }

        $this->loadMetadata();
    }

    public function sheetNames(): array
    {
        return array_keys($this->sheetPaths);
    }

    public function rows(string $sheetName): Generator
    {
        if (! isset($this->sheetPaths[$sheetName])) {
            throw new RuntimeException("Sheet not found: {$sheetName}");
        }

        $zip = $this->openZip();
        $zip->close();
        $reader = $this->xmlReader($this->sheetPaths[$sheetName]);

        try {
            while ($reader->read()) {
                if ($reader->nodeType === XMLReader::DOC_TYPE) {
                    throw new RuntimeException('Workbook XML contains a forbidden DOCTYPE.');
                }

                if ($reader->nodeType !== XMLReader::ELEMENT || $reader->localName !== 'row') {
                    continue;
                }

                $rowXml = $reader->readOuterXml();
                $row = simplexml_load_string($rowXml, SimpleXMLElement::class, LIBXML_NONET | LIBXML_COMPACT);
                if (! $row instanceof SimpleXMLElement) {
                    throw new RuntimeException("Invalid worksheet row XML: {$sheetName}");
                }

                $values = [];
                $hasValue = false;
                $rowNumber = (int) ($row['r'] ?? 0);

                foreach ($row->xpath('*[local-name()="c"]') ?: [] as $cell) {
                    $reference = (string) ($cell['r'] ?? 'A1');
                    $column = $this->columnNumber($reference);
                    $value = $this->cellValue($cell);
                    $values[$column] = $value;

                    if ($value !== '') {
                        $hasValue = true;
                    }
                }

                if ($hasValue) {
                    yield new SpreadsheetRow($rowNumber, $values);
                }
            }
        } finally {
            $reader->close();
        }
    }

    private function loadMetadata(): void
    {
        $zip = $this->openZip();
        try {
            $this->sharedStrings = $this->readSharedStrings($zip);
            $relationships = $this->readWorkbookRelationships($zip);

            $workbook = $this->xmlFromZip($zip, 'xl/workbook.xml');
            foreach ($workbook->xpath('//*[local-name()="sheets"]/*[local-name()="sheet"]') ?: [] as $sheet) {
                $attributes = $sheet->attributes(self::RELATIONSHIP_NS);
                $relationshipId = (string) ($attributes['id'] ?? $sheet['id'] ?? '');
                $target = $relationships[$relationshipId] ?? null;

                if ($target !== null) {
                    $this->sheetPaths[(string) $sheet['name']] = $this->normalizeWorkbookTarget($target);
                }
            }
        } finally {
            $zip->close();
        }
    }

    /** @return list<string> */
    private function readSharedStrings(ZipArchive $zip): array
    {
        if ($zip->locateName('xl/sharedStrings.xml') === false) {
            return [];
        }

        $xml = $this->xmlFromZip($zip, 'xl/sharedStrings.xml');
        $strings = [];

        foreach ($xml->xpath('//*[local-name()="si"]') ?: [] as $item) {
            $parts = [];

            foreach ($item->xpath('.//*[local-name()="t"]') ?: [] as $text) {
                $parts[] = (string) $text;
            }

            $strings[] = implode('', $parts);
        }

        return $strings;
    }

    /** @return array<string, string> */
    private function readWorkbookRelationships(ZipArchive $zip): array
    {
        $xml = $this->xmlFromZip($zip, 'xl/_rels/workbook.xml.rels');
        $relationships = [];

        foreach ($xml->xpath('//*[local-name()="Relationship"]') ?: [] as $relationship) {
            $relationships[(string) $relationship['Id']] = (string) $relationship['Target'];
        }

        return $relationships;
    }

    private function cellValue(SimpleXMLElement $cell): string
    {
        $type = (string) ($cell['t'] ?? '');

        if ($type === 's') {
            $index = (int) ($cell->v ?? -1);

            return $this->sharedStrings[$index] ?? '';
        }

        if ($type === 'inlineStr') {
            $parts = [];

            foreach ($cell->xpath('.//*[local-name()="t"]') ?: [] as $text) {
                $parts[] = (string) $text;
            }

            return implode('', $parts);
        }

        return isset($cell->v) ? (string) $cell->v : '';
    }

    private function columnNumber(string $cellReference): int
    {
        preg_match('/^[A-Z]+/i', $cellReference, $matches);
        $letters = strtoupper($matches[0] ?? 'A');
        $number = 0;

        foreach (str_split($letters) as $letter) {
            $number = ($number * 26) + (ord($letter) - 64);
        }

        return $number;
    }

    private function normalizeWorkbookTarget(string $target): string
    {
        $target = ltrim($target, '/');

        if (str_contains($target, '..')) {
            throw new RuntimeException('Invalid workbook relationship target.');
        }

        return str_starts_with($target, 'xl/') ? $target : 'xl/'.$target;
    }

    private function openZip(): ZipArchive
    {
        $zip = new ZipArchive;

        if ($zip->open($this->path) !== true) {
            throw new RuntimeException("Unable to open workbook: {$this->path}");
        }

        try {
            $this->validateArchive($zip);
        } catch (\Throwable $throwable) {
            $zip->close();

            throw $throwable;
        }

        return $zip;
    }

    private function xmlFromZip(ZipArchive $zip, string $path): SimpleXMLElement
    {
        $contents = $zip->getFromName($path);

        if ($contents === false) {
            throw new RuntimeException("Workbook entry not found: {$path}");
        }

        if (stripos($contents, '<!DOCTYPE') !== false) {
            throw new RuntimeException("Workbook XML contains a forbidden DOCTYPE: {$path}");
        }

        $xml = simplexml_load_string($contents, SimpleXMLElement::class, LIBXML_NONET | LIBXML_COMPACT);

        if (! $xml instanceof SimpleXMLElement) {
            throw new RuntimeException("Invalid workbook XML: {$path}");
        }

        return $xml;
    }

    private function xmlReader(string $path): XMLReader
    {
        $reader = new XMLReader;
        $uri = 'zip://'.str_replace('\\', '/', realpath($this->path) ?: $this->path).'#'.$path;

        if (! $reader->open($uri, null, LIBXML_NONET | LIBXML_COMPACT)) {
            throw new RuntimeException("Unable to stream workbook XML: {$path}");
        }

        $reader->setParserProperty(XMLReader::LOADDTD, false);
        $reader->setParserProperty(XMLReader::SUBST_ENTITIES, false);

        return $reader;
    }

    private function validateArchive(ZipArchive $zip): void
    {
        if ($zip->numFiles > self::MAX_ENTRIES) {
            throw new RuntimeException('Workbook contains too many archive entries.');
        }

        $totalSize = 0;
        for ($index = 0; $index < $zip->numFiles; $index++) {
            $stat = $zip->statIndex($index);
            if (! is_array($stat)) {
                throw new RuntimeException('Unable to inspect workbook archive.');
            }

            $size = (int) ($stat['size'] ?? 0);
            $compressedSize = (int) ($stat['comp_size'] ?? 0);
            $totalSize += $size;

            if ($size > self::MAX_ENTRY_BYTES || $totalSize > self::MAX_UNCOMPRESSED_BYTES) {
                throw new RuntimeException('Workbook exceeds the uncompressed size limit.');
            }

            if ($compressedSize > 0 && $size / $compressedSize > self::MAX_COMPRESSION_RATIO) {
                throw new RuntimeException('Workbook has an unsafe compression ratio.');
            }
        }
    }
}
