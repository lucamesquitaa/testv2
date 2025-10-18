<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class LogRequestData
{
    public function handle(Request $request, Closure $next)
    {
        // Log all request data for debugging
        Log::info('Request method: ' . $request->method());
        Log::info('Request content type: ' . $request->header('Content-Type'));
        Log::info('Request body: ' . $request->getContent());
        Log::info('Request all(): ', $request->all());
        Log::info('Request input(): ', $request->input());
        
        return $next($request);
    }
}