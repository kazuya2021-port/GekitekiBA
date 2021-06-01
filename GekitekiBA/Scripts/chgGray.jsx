function changeToGray()
{
// =======================================================
var id514 = charIDToTypeID( "CnvM" );
    var desc125 = new ActionDescriptor();
    var id515 = charIDToTypeID( "T   " );
        var desc126 = new ActionDescriptor();
        var id516 = charIDToTypeID( "Rt  " );
        desc126.putInteger( id516, 2 );
    var id517 = charIDToTypeID( "Grys" );
    desc125.putObject( id515, id517, desc126 );
executeAction( id514, desc125, DialogModes.NO );
// =======================================================
}
changeToGray();