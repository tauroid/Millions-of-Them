package;


import openfl.display.Sprite;
import openfl.text.TextField;


class Main extends Sprite {

    public function new () {
    	super ();
        
        var text = new TextField();

        text.text = "BOOYAH";

        addChild(text);
    }
    
    
}
