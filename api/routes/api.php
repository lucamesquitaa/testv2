<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TravelsController;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\DebugController;

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API is running',
        'timestamp' => now()->toISOString()
    ]);
});

// Rota POST de Travels (sem autenticação)
Route::post('/travels', [TravelsController::class, 'store']); // POST /api/travels

// Rotas para CRUD de Travels (protegidas com JWT)
Route::prefix('travels')->middleware('auth:api')->group(function () {
    Route::get('/', [TravelsController::class, 'index']); // GET /api/travels
    Route::get('/{id}', [TravelsController::class, 'show']); // GET /api/travels/{id}
    Route::put('/{id}', [TravelsController::class, 'update']); // PUT /api/travels/{id}
    Route::delete('/{id}', [TravelsController::class, 'destroy']); // DELETE /api/travels/{id}
});


// Rotas de autenticação (sem middleware)
Route::prefix('auth')->group(function () {
    Route::post('/login', [LoginController::class, 'login']);
    Route::post('/logout', [LoginController::class, 'logout'])->middleware('auth:api');
    Route::post('/refresh', [LoginController::class, 'refresh'])->middleware('auth:api');
    Route::get('/me', [LoginController::class, 'me'])->middleware('auth:api');
});

// Manter compatibilidade com a rota antiga
Route::post('/login', [LoginController::class, 'login']);