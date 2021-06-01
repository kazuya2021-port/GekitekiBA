function sikiiki_action()
{
//=========色域指定
    var id348 = charIDToTypeID( "ClrR" );
    var desc87 = new ActionDescriptor();
    var id349 = charIDToTypeID( "Fzns" );
    desc87.putInteger( id349, 200 );
    var id350 = charIDToTypeID( "Mnm " );
        var desc88 = new ActionDescriptor();
        var id351 = charIDToTypeID( "Lmnc" );
        desc88.putDouble( id351, 0.000000 );
        var id352 = charIDToTypeID( "A   " );
        desc88.putDouble( id352, 0.000000 );
        var id353 = charIDToTypeID( "B   " );
        desc88.putDouble( id353, 0.000000 );
    var id354 = charIDToTypeID( "LbCl" );
    desc87.putObject( id350, id354, desc88 );
    var id355 = charIDToTypeID( "Mxm " );
        var desc89 = new ActionDescriptor();
        var id356 = charIDToTypeID( "Lmnc" );
        desc89.putDouble( id356, 0.000000 );
        var id357 = charIDToTypeID( "A   " );
        desc89.putDouble( id357, 0.000000 );
        var id358 = charIDToTypeID( "B   " );
        desc89.putDouble( id358, 0.000000 );
    var id359 = charIDToTypeID( "LbCl" );
    desc87.putObject( id355, id359, desc89 );
executeAction( id348, desc87, DialogModes.NO );
//=========色域指定
}
sikiiki_action();