<?php

require_once __DIR__ . '/vendor/autoload.php';

use Illuminate\Database\Capsule\Manager as Capsule;

echo "=== Teste de Conexão com PostgreSQL ===\n\n";

try {
    // Configuração da conexão usando Eloquent Capsule
    $capsule = new Capsule;
    $capsule->addConnection([
        'driver' => 'pgsql',
        'host' => 'postgres',
        'port' => '5432',
        'database' => 'onfly_db',
        'username' => 'onfly_user',
        'password' => 'onfly_password',
        'charset' => 'utf8',
        'prefix' => '',
        'schema' => 'public',
    ]);

    $capsule->setAsGlobal();
    $capsule->bootEloquent();

    // Teste básico de conexão
    $pdo = $capsule->getConnection()->getPdo();
    echo "✅ Conexão PDO estabelecida com sucesso!\n";
    echo "Driver: " . $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) . "\n";
    echo "Versão do servidor: " . $pdo->getAttribute(PDO::ATTR_SERVER_VERSION) . "\n\n";

    // Teste de query simples
    $result = $capsule->getConnection()->select('SELECT version() as version, current_database() as database, current_user as user');
    echo "✅ Query executada com sucesso!\n";
    echo "PostgreSQL Version: " . $result[0]->version . "\n";
    echo "Database: " . $result[0]->database . "\n";
    echo "User: " . $result[0]->user . "\n\n";

    // Listar tabelas existentes
    $tables = $capsule->getConnection()->select("SELECT tablename FROM pg_tables WHERE schemaname = 'public'");
    echo "✅ Tabelas encontradas no banco:\n";
    foreach ($tables as $table) {
        echo "  - " . $table->tablename . "\n";
    }

    if (empty($tables)) {
        echo "  Nenhuma tabela encontrada. Execute as migrations primeiro.\n";
    }

    echo "\n=== Teste concluído com sucesso! ===\n";

} catch (Exception $e) {
    echo "❌ Erro na conexão: " . $e->getMessage() . "\n";
    echo "Código do erro: " . $e->getCode() . "\n";
    echo "Arquivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    exit(1);
}