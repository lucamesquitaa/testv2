<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Verificar se o usuário admin já existe
        $adminExists = User::where('email', 'admin@admin.com')->exists();
        
        if (!$adminExists) {
            // Criar usuário admin padrão
            User::create([
                'email' => 'admin@admin.com',
                'password' => Hash::make('admin'),
                'email_verified_at' => now(),
            ]);
            
            echo "Usuário admin criado com sucesso!\n";
        } else {
            echo "Usuário admin já existe no banco de dados.\n";
        }
    }
}
