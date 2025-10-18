<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Travel extends Model
{
    protected $table = 'travels';
    
    protected $fillable = [
        'Id',
        'Name',
        'Travel',
        'DateIn',
        'DateOut',
        'Status'
    ];
}
