<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class LoginController extends Controller
{
   
    /**
     * Store a newly created resource in storage.
     */
    public function login(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'email' => 'required|string|max:255',
                'password' => 'required|string|max:255'
            ]);

            $user = User::where('email', $validatedData['email'])->first();

            if (!$user || !Hash::check($validatedData['password'], $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Credenciais inválidas'
                ], 401);
            }

            // Gerar token simples (em produção, use JWT ou Laravel Sanctum)
            $token = base64_encode($user->id . ':' . time());

            return response()->json([
                'success' => true,
                'message' => 'Login realizado com sucesso',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'email_verified_at' => $user->email_verified_at,
                        'created_at' => $user->created_at,
                        'updated_at' => $user->updated_at
                    ],
                    'token' => $token
                ]
            ], 200);
        
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao realizar login',
                'error' => $e->getMessage()
            ], 500);
        }
    }

}
