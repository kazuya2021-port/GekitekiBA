function sikiiki_action()
{
//=========色域指定

var id48 = charIDToTypeID( "ClrR" );
    var desc13 = new ActionDescriptor();
    var id49 = charIDToTypeID( "Fzns" );
    desc13.putInteger( id49, 40 );
    var id50 = charIDToTypeID( "Mnm " );
        var desc14 = new ActionDescriptor();
        var id51 = charIDToTypeID( "Gry " );
        desc14.putDouble( id51, 100.000000 );
    var id52 = charIDToTypeID( "Grsc" );
    desc13.putObject( id50, id52, desc14 );
    var id53 = charIDToTypeID( "Mxm " );
        var desc15 = new ActionDescriptor();
        var id54 = charIDToTypeID( "Gry " );
        desc15.putDouble( id54, 100.000000 );
    var id55 = charIDToTypeID( "Grsc" );
    desc13.putObject( id53, id55, desc15 );
executeAction( id48, desc13, DialogModes.NO );
//=========色域指定
}
sikiiki_action();