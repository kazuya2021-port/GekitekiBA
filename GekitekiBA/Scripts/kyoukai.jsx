function kyoukaisen(size,trans)
{
var id236 = charIDToTypeID( "Strk" );
    var desc44 = new ActionDescriptor();
    var id237 = charIDToTypeID( "Wdth" );
    desc44.putInteger( id237, size );
    var id238 = charIDToTypeID( "Lctn" );
    var id239 = charIDToTypeID( "StrL" );
    var id240 = charIDToTypeID( "Cntr" );
    desc44.putEnumerated( id238, id239, id240 );
    var id241 = charIDToTypeID( "Opct" );
    var id242 = charIDToTypeID( "#Prc" );
    desc44.putUnitDouble( id241, id242, trans );
    var id243 = charIDToTypeID( "Md  " );
    var id244 = charIDToTypeID( "BlnM" );
    var id245 = charIDToTypeID( "Dslv" );
    desc44.putEnumerated( id243, id244, id245 );
    var id246 = charIDToTypeID( "Clr " );
        var desc45 = new ActionDescriptor();
        var id247 = charIDToTypeID( "Cyn " );
        desc45.putDouble( id247, 0.000000 );
        var id248 = charIDToTypeID( "Mgnt" );
        desc45.putDouble( id248, 0.000000 );
        var id249 = charIDToTypeID( "Ylw " );
        desc45.putDouble( id249, 0.000000 );
        var id250 = charIDToTypeID( "Blck" );
        desc45.putDouble( id250, 100.000000 );
    var id251 = charIDToTypeID( "CMYC" );
    desc44.putObject( id246, id251, desc45 );
executeAction( id236, desc44, DialogModes.NO );
}
kyoukaisen(arguments[0],arguments[1]);