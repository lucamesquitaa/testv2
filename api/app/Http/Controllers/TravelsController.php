<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Travel;

class TravelsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        try {
            $travels = Travel::all();
            return response()->json([
                'success' => true,
                'data' => $travels
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar viagens',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'Name' => 'required|string|max:255',
                'Travel' => 'required|string|max:255',
                'DateIn' => 'required|date',
                'DateOut' => 'required|date',
                'Status' => 'required|string|max:50'
            ]);

            $travel = Travel::create($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Viagem criada com sucesso',
                'data' => $travel
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar viagem',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        try {
            $travel = Travel::findOrFail($id);
            
            return response()->json([
                'success' => true,
                'data' => $travel
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Viagem não encontrada'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar viagem',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        try {
            $travel = Travel::findOrFail($id);

            $validatedData = $request->validate([
                'Id'=> 'sometimes|required|integer',
                'Name' => 'sometimes|required|string|max:255',
                'Travel' => 'sometimes|required|string|max:255',
                'DateIn' => 'sometimes|required|string',
                'DateOut' => 'sometimes|required|string',
                'Status' => 'sometimes|required|string|max:50'
            ]);

            $travel->update($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Viagem atualizada com sucesso',
                'data' => $travel
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Viagem não encontrada'
            ], 404);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar viagem',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        try {
            $travel = Travel::findOrFail($id);
            $travel->delete();

            return response()->json([
                'success' => true,
                'message' => 'Viagem excluída com sucesso'
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Viagem não encontrada'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir viagem',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
