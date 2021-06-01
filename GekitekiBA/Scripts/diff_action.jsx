function diff_action(){
var id116 = charIDToTypeID( "setd" );
    var desc24 = new ActionDescriptor();
    var id117 = charIDToTypeID( "null" );
        var ref15 = new ActionReference();
        var id118 = charIDToTypeID( "Lyr " );
        var id119 = charIDToTypeID( "Ordn" );
        var id120 = charIDToTypeID( "Trgt" );
        ref15.putEnumerated( id118, id119, id120 );
    desc24.putReference( id117, ref15 );
    var id121 = charIDToTypeID( "T   " );
        var desc25 = new ActionDescriptor();
        var id122 = charIDToTypeID( "Opct" );
        var id123 = charIDToTypeID( "#Prc" );
        desc25.putUnitDouble( id122, id123, 90.000000 );
        var id124 = charIDToTypeID( "Lefx" );
            var desc26 = new ActionDescriptor();
            var id125 = charIDToTypeID( "Scl " );
            var id126 = charIDToTypeID( "#Prc" );
            desc26.putUnitDouble( id125, id126, 208.333333 );
        var id127 = charIDToTypeID( "Lefx" );
        desc25.putObject( id124, id127, desc26 );
    var id128 = charIDToTypeID( "Lyr " );
    desc24.putObject( id121, id128, desc25 );
executeAction( id116, desc24, DialogModes.NO );
}
diff_action();