<?php

namespace Tests\Feature;

use App\Payments\Excel\XlsxWorkbookReader;
use RuntimeException;
use Tests\TestCase;
use ZipArchive;

class XlsxWorkbookReaderTest extends TestCase
{
    public function test_reader_reads_inline_strings_and_preserves_leading_zeroes(): void
    {
        $path = $this->workbook(<<<'XML'
            <?xml version="1.0" encoding="UTF-8"?>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
              <sheetData>
                <row r="7">
                  <c r="I7" t="inlineStr"><is><t>009001</t></is></c>
                  <c r="J7"><v>1</v></c>
                  <c r="K7" t="inlineStr"><is><t>001234</t></is></c>
                </row>
              </sheetData>
            </worksheet>
            XML);

        try {
            $rows = iterator_to_array((new XlsxWorkbookReader($path))->rows('MERCADEO'));

            $this->assertCount(1, $rows);
            $this->assertSame('009001', $rows[0]->value(9));
            $this->assertSame('001234', $rows[0]->value(11));
        } finally {
            @unlink($path);
        }
    }

    public function test_reader_rejects_doctype_declarations(): void
    {
        $path = $this->workbook(<<<'XML'
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE worksheet [<!ENTITY payload "forbidden">]>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
              <sheetData><row r="7"><c r="A7" t="inlineStr"><is><t>&payload;</t></is></c></row></sheetData>
            </worksheet>
            XML);

        try {
            $this->expectException(RuntimeException::class);
            iterator_to_array((new XlsxWorkbookReader($path))->rows('MERCADEO'));
        } finally {
            @unlink($path);
        }
    }

    private function workbook(string $worksheetXml): string
    {
        $path = storage_path('framework/testing/workbook-'.uniqid().'.xlsx');
        $zip = new ZipArchive;
        $this->assertTrue($zip->open($path, ZipArchive::CREATE | ZipArchive::OVERWRITE));
        $zip->addFromString('xl/workbook.xml', <<<'XML'
            <?xml version="1.0" encoding="UTF-8"?>
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
              <sheets><sheet name="MERCADEO" sheetId="1" r:id="rId1"/></sheets>
            </workbook>
            XML);
        $zip->addFromString('xl/_rels/workbook.xml.rels', <<<'XML'
            <?xml version="1.0" encoding="UTF-8"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
              <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
            </Relationships>
            XML);
        $zip->addFromString('xl/worksheets/sheet1.xml', $worksheetXml);
        $zip->close();

        return $path;
    }
}
