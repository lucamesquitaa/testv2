<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Travel;

class DebugController extends Controller
{
    public function testTravels()
    {
        try {
            $travels = Travel::all();
            return response()->json([
                'success' => true,
                'message' => 'Debug endpoint funcionando',
                'count' => $travels->count(),
                'data' => $travels->toArray()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro no debug',
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ], 500);
        }
    }

    public function testTravelsWithAuth()
    {
        try {
            $user = auth('api')->user();
            $travels = Travel::all();
            return response()->json([
                'success' => true,
                'message' => 'Debug com auth funcionando',
                'user' => $user ? $user->email : 'no user',
                'count' => $travels->count(),
                'data' => $travels->toArray()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro no debug com auth',
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ], 500);
        }
    }
}
