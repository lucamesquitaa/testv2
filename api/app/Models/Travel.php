<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Travel extends Model
{
    protected $table = 'travels';
    
    // A chave primária é 'id' (padrão do Laravel)
    protected $primaryKey = 'id';
    
    protected $fillable = [
        'Name',
        'Travel', 
        'DateIn',
        'DateOut',
        'Status'
    ];
}
