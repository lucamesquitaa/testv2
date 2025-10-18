<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TravelsController;

// Rotas para CRUD de Travels
Route::prefix('travels')->group(function () {
    Route::get('/', [TravelsController::class, 'index']); // GET /api/travels
    Route::post('/', [TravelsController::class, 'store']); // POST /api/travels
    Route::get('/{id}', [TravelsController::class, 'show']); // GET /api/travels/{id}
    Route::put('/{id}', [TravelsController::class, 'update']); // PUT /api/travels/{id}
    Route::delete('/{id}', [TravelsController::class, 'destroy']); // DELETE /api/travels/{id}
});