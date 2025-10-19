<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TravelsController;
use App\Http\Controllers\LoginController;

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API is running',
        'timestamp' => now()->toISOString()
    ]);
});

// Rotas para CRUD de Travels
Route::prefix('travels')->group(function () {
    Route::get('/', [TravelsController::class, 'index']); // GET /api/travels
    Route::post('/', [TravelsController::class, 'store']); // POST /api/travels
    Route::get('/{id}', [TravelsController::class, 'show']); // GET /api/travels/{id}
    Route::put('/{id}', [TravelsController::class, 'update']); // PUT /api/travels/{id}
    Route::delete('/{id}', [TravelsController::class, 'destroy']); // DELETE /api/travels/{id}
});


Route::prefix('login')->group(function () {
    Route::post('/', [LoginController::class,'login']);
});