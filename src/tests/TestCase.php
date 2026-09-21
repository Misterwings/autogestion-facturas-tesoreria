<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function refreshApplication(): void
    {
        parent::refreshApplication();

        $database = env('TEST_DB_CONNECTION', 'sqlite');
        config()->set('database.default', $database);
        if ($database === 'sqlite') {
            config()->set('database.connections.sqlite.database', ':memory:');
        }
        config()->set('cache.default', 'array');
        config()->set('queue.default', 'sync');
        config()->set('session.driver', 'array');
    }
}
