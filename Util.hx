import flash.filters.GlowFilter;
import flash.display.DisplayObjectContainer;

class Util{
	public static function index(a:Array<Dynamic>,item:Dynamic){
		for (i in 0...a.length) {
			if (item==a[i]) return i;
		}
		return -1;
	}
	public static function has(a:Array<Dynamic>,item:Dynamic){
		return (index(a,item)!=-1);
	}
	//binary search
	public static function search(a:Array<Int>,item:Int){
		//bad algorithm
		for (i in 0...a.length) {if (a[i]>item) return i;}
		return -1;
	}

	public static function randitem(a:Array<Dynamic>){
		var i = Std.random(a.length);
		return a[i];
	}

	public static function min(a:Array<Float>){
		var m = a[0];
		for (x in a) if (x<m) m=x;
		return m;
	}

	public static function tohash(a:Array<Array<Dynamic>>){
		var hash = new Hash<Dynamic>();
		for (kv in a) hash.set(kv[0],kv[1]);
		return hash;
	}

	public static function addborder(tf:Dynamic,col=0){
		var outline = new GlowFilter();
		outline.blurX = outline.blurY = 3;
		outline.color = col;
		outline.strength = 100;
		tf.filters = [outline];
	}

	public static function setxy(tf:Dynamic,x,y){
		tf.x=x;
		tf.y=y;
	}

	public static function removecond(par:DisplayObjectContainer,child:Dynamic){
		trace("Conditional removal");
		if (par.contains(child)) par.removeChild(child);
	}

	public static function toarray(it:Iterator<Dynamic>){
		var arr = [];
		for (item in it) arr.push(item);
		return arr;
	}
}