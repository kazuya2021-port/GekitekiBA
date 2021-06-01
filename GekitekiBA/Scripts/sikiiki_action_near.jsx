function sikiiki_action()
{
// =======================================================
var id3 = charIDToTypeID( "ClrR" );
    var desc2 = new ActionDescriptor();
    var id4 = charIDToTypeID( "Clrs" );
    var id5 = charIDToTypeID( "Clrs" );
    var id6 = charIDToTypeID( "Hghl" );
    desc2.putEnumerated( id4, id5, id6 );
executeAction( id3, desc2, DialogModes.NO );

// =======================================================
var id7 = charIDToTypeID( "Invs" );
executeAction( id7, undefined, DialogModes.NO );

}
sikiiki_action();