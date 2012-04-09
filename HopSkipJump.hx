import caurina.transitions.Tweener;
import caurina.transitions.properties.FilterShortcuts;
import caurina.transitions.properties.ColorShortcuts;
import caurina.transitions.properties.CurveModifiers;

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.KeyboardEvent;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import flash.display.Loader;
import flash.net.URLRequest;
//import flash.MovieClipLoader;

import flash.geom.Rectangle;

import flash.utils.Timer;

import flash.Error;

import flash.net.SharedObject;

import flash.net.LocalConnection;

import LibraryClasses;

using StringTools;
using Util;

class Data {
	public static var achievements;
	public static var unlocked;
	public static var keys;
	public static var ponies;
	public static var maxbg;
	public static var supermode;
	public static var supermodeunlocked;
	public static var besttime;
	public static var lastlevel;
	public static var version;

	public static var achievementsser;
	public static var besttimeser;

	public static function init(){
		var so:SharedObject = SharedObject.getLocal("userData");
		var alldata=so.data.alldata;
		if (alldata==null || Const.debugreset) Data.reset();
		else Data.load(alldata);
	}

	public static function reset(){
		Data.achievements = new Hash<String>();
		Data.achievements.set("started_game","got");
		Data.keys = [[49,50,51,52],[38,39],[57,48],[97,98]];
		Data.ponies = ["fs","pp","ts"];
		//Data.ponies = ["fs","pp","ts","ra"];
		Data.maxbg = 2;
		Data.unlocked = ["fs"];
		//Data.unlocked = ["fs","pp","ts","ra"];
		//Data.supermode = false;
		Data.besttime = new Hash<Float>();
		//Data.besttime.set("test",10000);
		Data.supermodeunlocked = false;
		Data.supermode = false;//false;//true;
		Data.lastlevel = 1;
		Data.version = "rc0";
	}

	public static function load(alldata){
		Data.achievements = haxe.Unserializer.run(alldata.achievementsser);
		Data.keys = alldata.keys;
		Data.ponies = alldata.ponies;
		Data.maxbg = alldata.maxbg;
		Data.unlocked = alldata.unlocked;
		Data.besttime = haxe.Unserializer.run(alldata.besttimeser);
		Data.supermodeunlocked = alldata.supermodeunlocked;
		Data.supermode = alldata.supermode;
		Data.lastlevel = alldata.lastlevel;
		Data.version = alldata.version;
	}

	public static function save(){
		trace("Saving...");
		Data.besttimeser=haxe.Serializer.run(Data.besttime);
		Data.achievementsser=haxe.Serializer.run(Data.achievements);
		var so:SharedObject = SharedObject.getLocal("userData");
		so.data.alldata=Data;
		so.flush();
		trace("Saved");
	}

	public static function setkeys(newkeys){
		Data.keys=[];		
		for (i in 0...3){
			Data.keys.push([newkeys[2*i],newkeys[2*i+1]]);
		}
		//Data.keys = newkeys;
	}

	public static function unlock(s){
		if (!Data.unlocked.has(s)){
			Data.unlocked.push(s);
		}
	}
}

class Res {
	public static var images;
	public static var sounds;

	public static var loadercount:Int;
	public static var complete;

	public static function init(complete){
		Res.complete = complete;
		Res.images = new Hash<BitmapData>();

		loadercount = 0;

		Res.sounds=new Hash<Sound>();
		//"HopSkipJumpBeta.mp3"
		for (sndfile in Const.sndfiles){
			var sound:Sound=new Sound();
			sound.load(new URLRequest(sndfile[1]));
			sounds.set(sndfile[0],sound);
		}

		for (file in Const.staticfiles){
			var filename = file[0];
			var name = file[1];
			var loader = new Loader();
			loader.load(new URLRequest(filename));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, callback(loaded,name));
			loadercount += 1;
		}

		var files = Const.files;
		for (file in files){
			var prefix:String = Const.img+file[0];
			var name:String = file[1];
			var len:Int = file[2];
			var speed:Int = file[3];
			var asprite = new ASprite(speed);
			for (i in 0...len){
				if (!Const.dynamicload.has(file[0])){
					loaded2(prefix+i+".gif");
				//Testing for images not built into the swf
				} else {
					var loader = new Loader();
					//if (file[0].charAt(0)=="/") loader.load(new URLRequest(file[0].substr(1)+i+".gif")); 
					//else loader.load(new URLRequest(prefix+i+".gif")); 
					prefix="img/"+file[0];
					loader.load(new URLRequest(prefix+i+".gif")); 
					prefix=Const.img+file[0];
					//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, callback(loaded,name+i));
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, callback(loaded,prefix+i+".gif"));
				}
				loadercount += 1;
			}
		}
	}

	public static function loaded(name:String,ev:Event){
		//trace(ev);
		var bm:Bitmap = cast ev.target.content;
		var bmd:BitmapData = bm.bitmapData;
		images.set(name,bmd);
		loadercount -= 1;
		if (loadercount==0) {
			trace("All images loaded");
			//trace(complete);
			//trace(Res.complete);
			Res.complete();
		}
	}

	public static function loaded2(name:String){
		//trace(ev);
		//var bm:Bitmap = cast ev.target.content;
		var classname = name.substr(5);
		classname=classname.replace(".gif","_png");
		classname=classname.replace("-","_");
		classname = name.charAt(4).toUpperCase()+classname;
		//trace(classname);
		//var bm:Bitmap = cast ev.target.content;
		//try {
		var bm:Bitmap = Type.createInstance(Type.resolveClass(classname),[]);
		/*} catch (e:Dynamic) {
			trace(name+" Not Ok");
		}*/
		//var bm = Type.createInstance(Type.resolveClass("Pp_copter_stop_30_png"),[]);
		var bmd:BitmapData = bm.bitmapData;
		images.set(name,bmd);
		loadercount -= 1;
		if (loadercount==0) {
			trace("All images loaded");
			//trace(complete);
			//trace(Res.complete);
			Res.complete();
		}
	}

}

class Uti {
	//draws or loads a gem
	public static function gem(val){
		var newspr=new Sprite();
		var magic = Uti.loadasprite("ra-magic-aura",1);
		newspr.addChild(magic);
		if (val=="dark"){
			var newbm = new Bitmap(Res.images.get("ruby"));
			newbm.cacheAsBitmap = true;
			newspr.addChild(newbm);
		} else if (val=="light"){
			var newbm = new Bitmap(Res.images.get("sapphire"));
			newbm.cacheAsBitmap = true;
			newspr.addChild(newbm);
		}
		return newspr;
	}

	//draws a black circle
	public static function circle(radius,col=0){
		var rect = new Sprite();
		var g = rect.graphics;
		g.beginFill(col);
		g.drawCircle(0,0,radius);
		g.endFill();
		return rect;
	}

	//draws a black rectangle
	public static function rect(width,length,col=0){
		var rect = new Sprite();
		var g = rect.graphics;
		g.beginFill(col);
		g.drawRect(0,0,width,length);
		g.endFill();
		return rect;
	}

	public static function loadasprite(name:String,paramnum=0) {
		var files = Const.files;
		//Needs a dictionary for file to get a better way for reverse lookup
		for (file in files){
			if (file[paramnum]==name){
				var prefix = Const.img+file[0];
				var name:String = file[1];
				var len:Int = file[2];
				var speed:Int = file[3];
				var frametimes:Array<Int> = file[4].copy();
				for (i in 1...frametimes.length) frametimes[i]+=frametimes[i-1];
				for (i in 0...frametimes.length) frametimes[i]*=speed;
				
				var asprite = new ASprite(speed,frametimes);
				for (i in 0...len){
					var newbm = new Bitmap(Res.images.get(prefix+i+".gif"));
					//trace(prefix+i+".gif");
					//trace(Res.images.get(prefix+i+".gif"));
					newbm.cacheAsBitmap = true;
					asprite.addframe(newbm);
				}
				asprite.buildframetimes();
				return asprite;
			}
		}
		return null;
	}

	public static function scrollRectScroll(parent:Dynamic,newx){
		var rect = parent.scrollRect;
		rect.x = newx;
		parent.scrollRect = rect;
	}

	public static function scrollRectScrollAdd(parent:Dynamic,newx:Float){
		var rect = parent.scrollRect;
		rect.x += newx;
		parent.scrollRect = rect;
	}

	public static function capscrollrect(parent:Dynamic){
		//var maxx = (Const.racelen-10)*(Const.tilex)-100
		var maxx = (Const.racelen)*(Const.tilex)-100;
		if (parent.scrollRect.x>maxx){
			Uti.scrollRectScroll(parent,maxx);
		}
	}

	public static function addgamewindow(game:MovieClip,gamewindow:MovieClip,winy=0){
		game.addChild(gamewindow);
		gamewindow.y = winy;
		//Debugging! Did this work??
		game.addChild(gamewindow.timertf);
		gamewindow.timertf.y = gamewindow.y;
		game.gamewindows.push(gamewindow);
	}
}

class Const {
	//Uncomment part of these and comment the next section to enable some debugging codes.

	/*public static var debug=true;
	public static var debugchickenbg=false;
	public static var debugkeys=false;
	public static var debugponies=true;
	//public static var debugponies=false;
	public static var debugpony="ra";
	public static var debugfaststart=true;
	//public static var debugfaststart=false;
	public static var debugmultiplayer=true;
	//public static var debugreset=true;
	public static var debugreset=false;
  public static var debugmoreice=false;
  public static var debugbganim=true*/

	//public static var debug=true;
	public static var debug=false;
	public static var debugchickenbg=false;
	public static var debugkeys=false;
	public static var debugponies=false;
	public static var debugpony="";
	public static var debugfaststart=false;
	public static var debugmultiplayer=false;
	public static var debugreset=false;
	public static var debugmoreice=false;
	public static var debugbganim=false;

	public static var mc;
	public static var mcs;

	public static var img = "img/";
	public static var imgs = "imgs/";

	public static var numlevels=6;

	public static var frameratems=42;
	public static var racelen=98;
	//public static var racelen=20;

	public static var millis=1000;

	//Background image
	public static var bgwidth=640;
	//Animation
	public static var bgx=100;
	public static var bgmovex=2;

	public static var floordiffy=50;

	public static var colpp=0xFBC5DF;
	public static var colfs=0xFDF7A5;
	public static var colts=0xC8A9CF;
	public static var colra=0xF7FDFF;
	public static var colsb=0xF0F0F0;

	public static var colfsout=0xF592C5;
	public static var coltsout=0xAD75C1;
	public static var colppout=0xDA4396;
	public static var colraout=0x3E2F7F;
	public static var colsbout=0xB993C4;// 0xF4B7DA;

	public static var files =
		[["pp-stand-","pp-stand",16,3,
			[0,10,1,1,1,1,1,20,1,1,1,1,1,20,1,1,20]],
		 ["pp-jump-","pp-jump",12,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1]],
		 ["pp-jump-","pp-skip",12,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1]],
		 ["pp-jumpnn-","pp-jumpnn",12,2,
			[0,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["pp-jumpnn-","pp-skipnn",12,2,
			[0,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["pp-jump-","pp-slide",12,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1]],
		 ["pp-falloff-","pp-fall",6,2,
			[0,1,1,1,1,1,1]],
		 ["pp-fall-","jump_fall",18,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1]],
		 ["pp-fall-","skip_fall",18,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1]],
		 ["pp-fly-","pp-fly",7,1,
			[0,1,1,1,20,1,1,20]],
		 ["pp-win-","pp-win",12,1,
			[0,1,1,1,1,1,1,1,3,1,1,1,1]],
		 ["pp-copter-","pp-copter",20,1,
			[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
		 ["pp-copter-stop-","pp-copter-stop",38,1,
			[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1]],
		 ["pp-cupcake-","pp-super",50,2,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["ts-stand-","ts-stand",16,3,
			[0,10,1,1,1,1,1,20,1,1,1,1,1,20,1,1,10]],
		 ["ts-teleport-","ts-teleport",35,1,
			[0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["ts-teleport-","ts-super",35,1,
			[0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["ts-arrive-","ts-arrive",19,1,
			[0,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]],
		 ["ts-teleport-","ts-teleport-home",35,1,
			[0,2,2,2,2,2,2,2,2,2,2,2,
2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["ts-arrive-","ts-arrive-home",19,1,
			[0,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]],
		 ["ts-arrive-","ts-arrive-super-slide",19,1,
			[0,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]],
		 ["ts-arrive-","ts-arrive-super-teleport",19,1,
			[0,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]],
		 ["ts-arrive-","ts-arrive-super-skip",19,1,
			[0,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]],
		 ["ts-arrive-","ts-fly",19,1,
			[0,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]],
		 ["t-fall-","ts-fall",14,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["ts-win-","ts-win",60,1,
			[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
		 ["pp-jump-","ts-skip",12,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1]],
		 ["pp-jump-","ts-slide",12,2,
			[0,1,1,1,1,1,1,1,2,1,1,1,1]],
		 ["fs-stand-","fs-stand",18,3,
			[0,10,1,1,1,1,1,20,1,1,1,1,1,1,20,1,20,1,20]],
		 ["fs-hop-","fs-hop",16,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["fs-hop-","fs-skip",16,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["fs-hop-","fs-slide",16,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["fs-fly-","fs-fly",16,2,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["fs-sleep-","fs-win",2,1,
			[0,20,20]],
		 ["fs-fall-","fs-fall",14,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["fs-super-","fs-super",34,2,
			[0,1,1,1,1,10,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,1,1,1,9]],
		 ["sb-jump-right-","ra-jump",8,1,
			[0,2,2,2,3,2,2,2,2]],
		 ["sb-jump-right-","ra-skip",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["sb-jump-left-","ra-slide",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["sb-jump-right-","ra-rasuper-jump",8,1,
			[0,2,2,2,3,2,2,2,2]],
		 ["sb-jump-right-","ra-rasuper-skip",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["sb-jump-left-","ra-rasuper-slide",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["sb-jump-left-","ra-back-jump",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["sb-jump-left-","ra-back-skip",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["sb-jump-right-","ra-back-slide",8,1,
			[0,2,2,2,3,2,2,2,4]],
		 ["r-magic-","ra-magic",6,1,
			[0,1,1,1,1,1,1]],
		 ["ra-magic-left-","ra-magic-left",6,1,
			[0,3,3,3,3,3,3]],
		 ["ra-magic-redo-","ra-magic-aura",7,1,
			[0,3,3,3,3,3,3,3]],
		 ["r-stand-","ra-stand",16,3,
			[0,10,1,1,1,1,1,20,1,1,1,1,1,20,1,1,20]],
		 ["sb-pointnear-","ra-stand-skip",6,3,
			[0,2,1,1,5,1,1]],
		 ["sb-point-","ra-stand-jump",6,3,
			[0,2,1,1,5,1,1]],
		 ["sb-point-","ra-stand-null",6,3,
			[0,2,1,1,5,1,1]],
		 ["sb-sit-","ra-super",5,1,
			[0,1,1,1,1,5]],
		 ["derpy-fly-","derpy-bg",16,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["rd-bg-zoom-","rd-bg",16,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["bg-tank--","tank-bg",20,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ["bg-spitfire--","spitfire-bg",16,1,
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
		 ];
	//More bgs: gilda, raindrops, guard
	/*public static var dynamicload = ["bg-tank--","bg-spitfire--","ra-stand-skip-","ra-stand-jump-","ra-magic-left-","fs-super-","ra-magic-redo-","sb-point-","sb-pointnear-","sb-jump-right-","sb-jump-left-","sb-sit-"];*/

	public static var dynamicload = [];

	public static var staticfiles =
		[["custom/cloudnew-2.png","cloud"],
		 //["images/cloud.png","button"],
		 ["custom/cloud-button.png","button"],
		 ["custom/cloud-pressed.png","button-pressed"],
		 ["custom/cloudbouncy-2.png","ice"],
		 ["images/title.png","title"],
		 ["custom/ruby-1.png","ruby"],
		 ["custom/sapphire-2.png","sapphire"],
		 //["img/bg.png","bg"],
		 ["images/bgcrop.png","bg"],
		 //["images/bg3.png","bg3"],
		 ["images/bg4.png","bg4"],
		 ["images/bg5.png","bg5"],
		 ["images/bg6.png","bg6"],
		 ["images/bg7b.png","bg7"],
		 ["images/Spm-ajfarm.png","bg3"],
		 ["custom/selectts.gif","select ts"],
		 ["custom/selectpp.gif","select pp"],
		 ["custom/selectfs.gif","select fs"],
		 ["custom/selectra.gif","select ra"],
		 ["custom/cloud-tiny.png","cloud-small"],
		 ["custom/spring-tiny2.png","spring-small"],
		 ["custom/button-tiny.png","button-small"],
		 ["images/pinkie-surprise-s.png","pinkie-surprise"],
		 ["images/fluttershy-unsure-s.png","fluttershy-unsure"],
		 ["images/twilight-surprised-s.png","twilight-surprised"],
		 ["images/pinkie-happynn-s.png","pinkie-happynn"],
		 ["images/rarity-confused-s.png","rarity-confused"],
		 ["images/rarity-disgust-s.png","rarity-disgust"],
		 ["images/rarity-inspired-s.png","rarity-inspired"],
		 ["images/sb-cheer-s.png","sb-cheer"],
		 ["images/sb-unsure-s.png","sb-unsure"],
		 ["custom/superbg2.png","superbg"],
];

	public static var sndfiles =
		[["bgm","music/MLP-Applejack.mp3"],
		 ["bgmpp","music/MLP-PinkiePie.mp3"],
		 ["bgmts","music/MLP-TwilightSparkle.mp3"],
		 ["bgmra","music/MLP-Rarity.mp3"],
		 ["ppsuper","music/cupcakes.mp3"],
		 ["tssuper","music/tschecklist.mp3"],
		 ["fssuper","music/squeak.mp3"],
		 ["rasuper","music/sbgot.mp3"],
		 ["jump1","sfxr/jump.mp3"],
		 ["jump2","sfxr/jump2.mp3"]];

	public static var tilex = 44;
	public static var floorxoffset = 40;
	public static var mapxoffset = 40;

	public static function format(name="default"){
		var format:TextFormat = new TextFormat();
		format.align = TextFormatAlign.LEFT;
		format.color = 0;
		if (name=="default"){
			format.font = null;
			format.size = 8;
		} else if (name=="mlp"){
			format.font = "fontmlp";
			format.size = 12;
		} else if (name=="mlpcredit"){
			format.font = "fontmlp";
			format.size = 18;
		} else if (name=="medium"){
			format.font = "fontmlp";
			format.size = 24;
		} else if (name=="derpy"){
			format.font = "fontderpy";
			format.size = 24;
		} else if (name=="title"){
			format.font = "fontmlp";
			format.size = 38;
		}
		return format;
	}

	public static function textfield(text="hello",format="title",textcol=-1,bordercol=-1){
		var tf = new TextField();
		tf.defaultTextFormat = Const.format(format);
		//tf.autoSize = TextFieldAutoSize.CENTER;
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.embedFonts=true;
		tf.text = text;
		if (textcol!=-1) tf.textColor = textcol;
		if (bordercol!=-1) tf.addborder(bordercol);
		return tf;
	}

	//Default conversation textfield
	public static function convtextfield(text,textcol=0){
		var tf = new TextField();
		tf.defaultTextFormat = Const.format("medium");
		tf.autoSize = TextFieldAutoSize.CENTER;
		tf.embedFonts=true;
		tf.selectable=false;
		tf.text = text;
		tf.x=30;
		tf.y=50-tf.height/2;
		tf.textColor=textcol;
		return tf;
	}

	//Default credits textfield
	public static function credittf(text,col=0){
		var tf = new TextField();
		tf.defaultTextFormat = Const.format("mlpcredit");
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.embedFonts = true;
		tf.text = text;
		tf.textColor = col;
		return tf;
	}

	public static var ponyname;
	public static var ponyabbr;

	public static function init(){
		Const.mc=flash.Lib.current;
		Const.mcs=flash.Lib.current.stage;

		var ponyname = new Hash<String>();
		var ponyabbr = new Hash<String>();
		var dictarray =
			[["pp","Pinkie Pie"],
			 ["ts","Twilight"],
			 ["fs","Fluttershy"],
			 ["ra","Rarity"]];
		for (kv in dictarray){
			ponyname.set(kv[0],kv[1]);
			ponyabbr.set(kv[1],kv[0]);
		}
		Const.ponyname = ponyname;
		Const.ponyabbr = ponyabbr;
	}
}

class AchievementScreen extends Sprite {
	public var par:HopSkipJump;
	public var textlayer:Sprite;

	public function new(par){
		super();
		this.par = par;

		var newbm = new Bitmap(Res.images.get("title"));
		this.addChild(newbm);

		settext();
		
		//dangerous
		Const.mcs.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
		this.disable();
	}

	public function settext(){
		if (textlayer!=null) this.removeChild(textlayer);
		textlayer = new Sprite();
		this.addChild(textlayer);

		var tf = Const.convtextfield("Best times",Const.colts);
		tf.width=350;tf.y=0;
		tf.addborder(Const.coltsout);
		textlayer.addChild(tf);

		var y = 30;

		var keys:Array<String>=Data.besttime.keys().toarray();
		keys.sort(Reflect.compare);
		for (lvl in keys){
			var tf = Const.credittf(lvl+":"+Data.besttime.get(lvl),Const.colfs);
			tf.x=0;tf.y=y;
			tf.addborder(Const.colfsout);
			textlayer.addChild(tf);
			y+=20;
		}

		var tf = Const.convtextfield("Achievements",Const.colts);
		tf.width=350;tf.y=y;
		tf.addborder(Const.coltsout);
		textlayer.addChild(tf);
		y+=30;

		var keys:Array<String>=Data.achievements.keys().toarray();
		keys.sort(Reflect.compare);
		for (ach in keys){
			var tf = Const.credittf(ach,Const.colfs);
			tf.x=0;tf.y=y;
			tf.addborder(Const.colfsout);
			textlayer.addChild(tf);
			y+=20;
		}

	}

	public function disable(){
		this.visible = false;
	}

	public function enable(){
		settext();
		this.visible = true;
	}

	public function kdown(ev:KeyboardEvent){
		if (!this.visible) return;
		if ([13,49,50].has(ev.keyCode)){
			this.disable();
			par.title.enable();
		}
	}
}

class CreditsScreen extends Sprite {
	public var par:HopSkipJump;
	public var alltext:Sprite;

	public function new(par){
		super();
		this.par = par;

		var newbm = new Bitmap(Res.images.get("title"));
		this.addChild(newbm);

		alltext = new Sprite();

		var tf = Const.convtextfield("Credits",Const.colfs);
		tf.x=200-tf.width;tf.y=0;
		tf.addborder(Const.colfsout);
		alltext.addChild(tf);

		var credity = 20;

		var disclaimer = "My Little Pony: Friendship is Magic is © Hasbro. This game is not affiliated with Hasbro, The Hub or its associates.";

		var credhash = new Hash<Array<String>>();
		//credhash.set("Sprites",["Jay Wright","deathpwny","RJP","sidekick ponyguy*","StarStep+","Bot-chan*","humle","Drinkie Pie (Midnyte)*"]);
		credhash.set("Sprites",["the various artists from Desktop Ponies"]);
		credhash.set("Vectors",["RainbowCrash","RelaxingOnTheMoon","Peachspices","dropletx1*","Issyrael","grendopony*","SpmSL","pokerface3699*","generalzoi's Pony Creator"]);
		credhash.set("Music",["Andrew Stein"]);
		credhash.set("Font",["Mattyhex"]);
		credhash.set("Programming",["Cantorlot"]);
		var credkeys = ["Sprites","Vectors","Music","Programming"];
		for (key in credkeys){
			var people=credhash.get(key);
			credity+=10;
			var tf = Const.convtextfield(key,Const.colfs);
			tf.x=0;tf.y=credity;
			tf.addborder(Const.colfsout);
			alltext.addChild(tf);
			credity+=30;

			for (i in 0...people.length){
				var tf = Const.credittf(people[i],Const.colfs);
				tf.y=credity;
				if (i%2==0){
					tf.x=10;
				} else {
					tf.x=210;
					credity+=20;
				}
				tf.addborder(Const.colfsout);
				alltext.addChild(tf);
			}
			if (people.length%2==1) credity+=20;
		}
		var tf = Const.convtextfield("",Const.colfs);
		tf.x=0;tf.y=credity;
		tf.width=350;
		tf.wordWrap=true;
		tf.text=disclaimer;
		tf.addborder(Const.colfsout);
		alltext.addChild(tf);

		this.addChild(alltext);
		//dangerous
		Const.mcs.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
		this.disable();
	}

	public function disable(){
		this.visible = false;
	}

	public function enable(){
		this.visible = true;
	}

	public function kdown(ev:KeyboardEvent){
		if (!this.visible) return;
		if (ev.keyCode==50){
			this.disable();
			par.title.enable();
		} else if (ev.keyCode==49){
			//Switch between two screens
			if (alltext.y==0) alltext.y=-300;
			else alltext.y=0;
		}
	}
}

class TitleScreen extends Sprite {
	public var par:HopSkipJump;
	public var mainmenu:TextField;
	public var optionmenu:TextField;
	public var menulevel:String;
	public var newkeys:Array<Int>;
	public var keymenu:TextField;

	public function new(par){
		super();
		this.par = par;

		var newbm = new Bitmap(Res.images.get("title"));
		this.addChild(newbm);
		var tf = Const.textfield("A hop skip\nand a jump",
														 "title",
														 Const.colfs,
														 Const.colfsout);
		tf.setxy(20,15);
		this.addChild(tf);

		mainmenu = Const.textfield("1.Single player\n2.Multiplayer\n3.Options\n4.Credits",
														 "mlp",
														 Const.colfs,
														 Const.colfsout);
		mainmenu.setxy(150,220);
		this.addChild(mainmenu);

		optionmenu = Const.textfield("",
														 "mlp",
														 Const.colfs,
														 Const.colfsout);
		optionmenu.setxy(400,220);
		this.addChild(optionmenu);
		optionmenu.visible=false;
		regenerateoptions();

		keymenu = Const.textfield("Press key 1 for player 1",
														 "mlp",
														 Const.colts,
														 Const.coltsout);
		keymenu.setxy(150,220);
		this.addChild(keymenu);
		keymenu.visible=false;

		menulevel="main";

		//dangerous
		Const.mcs.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
	}

	public function kdown(ev:KeyboardEvent){
		if (!this.visible) return;
		trace("keyCode "+ev.keyCode);
		if (menulevel=="main"){
			//Debugging function (press enter)
			if (ev.keyCode==13){
				//par.selectpony();
				//Data.besttime.set("test2",12345);
				//trace(Data.besttime);
				//par.startlevel(3,["Fluttershy"]);
				//par.startlevel(2,["Rarity"]);
				//par.playanimation(5,["Fluttershy"]);
				//par.startlevel(1,["Rarity"]);
				par.playanimation(3);


				//trace(untyped __global__ ["flash.utils.describeType"](String)); 
				//MemoryTracker.printall();
				//s=null;
				//MemoryTracker.gcAndCheck();

				//Remember to save game version!
				var so:SharedObject = SharedObject.getLocal("userData");
				//Save
				/*so.data.test="testing";
				so.flush();*/
				/*so.data.alldata=Data;
				so.flush();*/
				//Load
				var test:String = so.data.test;
				trace(test);
				var test2 = so.data.dummy;
				trace(test2);
				trace(Type.getClassFields(Data));
				trace(Reflect.fields(Data));
				var test3 = so.data.alldata.ponies;
				trace(test3);
				//var alldata:Data = so.data.alldata;
				trace(Type.getClassFields(Type.getClass(so.data.alldata)));
				trace(so);
				//so.data.alldata
				/*} else if (ev.keyCode==66){
				trace("Making a lot of sprites");
				var s;
				for (i in 0...100){
					s = new Sprite();
					MemoryTracker.track(s,"spr"+i);
				}
				s=null;*/
			} else if (ev.keyCode==49){
				if (Data.unlocked.length==1){
					par.startlevel(Data.lastlevel,["Fluttershy"]);
				} else {
					par.selectpony();
				}
			} else if (ev.keyCode==50){
				par.selectpony(-1);
			} else if (ev.keyCode==51){
				Tweener.addTween(mainmenu,{x:-400,time:1});
				regenerateoptions();
				optionmenu.visible=true;
				optionmenu.x=400;				
				Tweener.addTween(optionmenu,{x:150,time:1});
				menulevel="options";
			} else if (ev.keyCode==52){
				this.disable();
				par.credits.enable();
			} else if (ev.keyCode==53){
				this.disable();
				par.achscreen.enable();
			}
		} else if (menulevel=="options"){
			if (ev.keyCode==49){
				menulevel="keys";
				keymenu.visible=true;
				newkeys=[];
				keymenu.text="Press key 1 for player 1";
			} else if (ev.keyCode==50){
				if (Data.supermodeunlocked){
					Data.supermode = !Data.supermode;
					regenerateoptions();
				}
			} else if (ev.keyCode==51){
				this.disable();
				par.achscreen.enable();
			} else if (ev.keyCode==52){
				Tweener.addTween(mainmenu,{x:150,time:1});
				Tweener.addTween(optionmenu,{x:400,time:1});
				menulevel="main";
				Data.save();
			}
		} else if (menulevel=="keys"){
			newkeys.push(ev.keyCode);
			var pnum = 1+Std.int(newkeys.length/2);
			var knum = 1+(newkeys.length%2);
			keymenu.text="Press key "+knum+" for player "+pnum;
			if (newkeys.length==6){
				trace("New keys"+newkeys);
				Data.setkeys(newkeys);
				keymenu.visible=false;
				menulevel="options";
			}
		}
	}

	public function regenerateoptions(){
		var s = "1.Set keys\n";
		if (Data.supermodeunlocked) {
			s+="2.Toggle super mode ";
			if (Data.supermode) s+="(now on)";
			else s+="(now off)";
		}
		s+="\n3.Best times\n4.Back";
		optionmenu.text=s;
	}

	//There has to be a better way to do this
	public function disable(){
		this.visible = false;
	}

	public function enable(){
		this.visible = true;
		Data.save();
	}
}

class GameOverScreen extends Sprite {
	public var par:HopSkipJump;

	public function new(par){
		super();
		this.par = par;

		var rect = Uti.rect(200,200);
		rect.x=100;
		rect.y=50;
		this.addChild(rect);

		var tf:TextField = Const.convtextfield("You lost.\nTry again?\n1. Yes\n2. No", Const.colfs);
		tf.x = 200-tf.width/2;
		tf.y = 150-tf.height/2;
		tf.addborder(Const.colfsout);
		this.addChild(tf);

		//dangerous
		Const.mcs.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
		this.disable();
	}

	public function kdown(ev:KeyboardEvent){
		if (!this.visible) return;
		trace("keyCode "+ev.keyCode);
		if (ev.keyCode==49){
			this.disable();
			var levelnum=par.game.levelnum;var ponies=par.game.ponies.copy();
			par.startlevel(levelnum,ponies);
		} else if (ev.keyCode==50){
			this.disable();
			par.removegame();
			par.title.enable();
		}
	}

	//There has to be a better way to do this
	public function disable(){
		this.visible = false;
	}

	public function enable(){
		this.visible = true;
	}
}

class InterlevelScreen extends Sprite {
	public var par:HopSkipJump;
	public var type:String;
	public var tf:TextField;
	public var nextlevelnum:Int;

	public function new(par){
		super();
		this.par = par;

		var rect = Uti.rect(200,200,Const.colts);
		rect.x=100;
		rect.y=50;
		this.addChild(rect);

		tf = Const.convtextfield("You lost.\nTry again?\n1. Yes\n2. No", Const.colfs);
		tf.x = 200-tf.width/2;
		tf.y = 150-tf.height/2;
		tf.addborder(Const.colfsout);
		this.addChild(tf);

		//dangerous
		this.disable();
	}

	public function settype(newtype:String,nextlevelnum=-1,racetime=-1,newbesttime:Bool=false){
		if (newtype=="lastlevel"){
			var txt="You won!\n";
			if (racetime>0) txt+="Time: "+racetime+"\n";
			if (newbesttime) txt+="New best time!";
			txt+="\n";
			txt+="Super mode\nunlocked!\n";
			txt+="1.Main menu";
			settext(txt);
			this.type=newtype;
		} else if (newtype=="nextlevel"){
			var txt="";
			if (par.game.levelnum>1) txt="You won!";
			txt+=" \n";
			if (racetime>0) txt+="Time: "+racetime+"\n";
			if (newbesttime) txt+="New best time!";
			txt+="\n";
			txt+="1.Continue\n2.Main menu";
			settext(txt);
			this.nextlevelnum=nextlevelnum;
			Data.lastlevel = nextlevelnum;
			this.type=newtype;
		}
	}

	public function settext(newtext:String){
		tf.text = newtext;
		tf.x = 200-tf.width/2;
		tf.y = 150-tf.height/2;
	}

	public function kdown(ev:KeyboardEvent){
		if (!this.visible) return;
		trace("keyCode "+ev.keyCode);
		if (ev.keyCode==49){
			this.disable();
			if (type=="lastlevel") {
				par.removegame();
				par.title.enable();
			} else if (type=="nextlevel") {
				var ponies=par.game.ponies.copy();
				par.startlevel(nextlevelnum,ponies);
			}
		} else if (ev.keyCode==50){
			if (type=="nextlevel") {
				this.disable();
				par.removegame();
				par.title.enable();
			}
		}
	}

	//There has to be a better way to do this
	public function disable(){
		this.visible = false;
		Const.mcs.removeEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
	}

	public function enable(){
		this.visible = true;
		Const.mcs.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
	}
}

//Multiple asprites
class MSprite extends Sprite {
	var asprites:Hash<ASprite>;
	public var state:String;
	public var falling:Bool;
	public var game:GameWindow;
	public var statecount:Int;
	public var paused:Bool;

	public var stepsize:Hash<Int>;
	public var xoffset:Int;
	public var yoffset:Int;
	public var pony:String;

	public var cursprite:ASprite;
	public function new(game,pony){
		super();
		MemoryTracker.track(this,"msprite");

		this.game=game;
		this.asprites = new Hash<ASprite>();

		//var pony = "Twilight";
		//var pony = "Pinkie Pie";
		this.pony = pony;

		this.stepsize = new Hash<Int>();
		this.stepsize.set("teleport",7);
		this.stepsize.set("jump",3);
		//this.stepsize.set("skip",-1);
		this.stepsize.set("slide",-1);
		this.stepsize.set("jump_fall",this.stepsize.get("jump"));
		this.stepsize.set("skip_fall",this.stepsize.get("skip"));

		if (pony == "Twilight"){
			this.stepsize.set("skip",-1);
			this.xoffset = -25;
			this.yoffset = 0;
		} else if (pony == "Pinkie Pie"){
			this.stepsize.set("jumpnn",3);
			this.stepsize.set("skipnn",2);
			this.stepsize.set("skip",2);
			this.xoffset = 0;
			this.yoffset = 0;
		} else if (pony == "Fluttershy"){
			this.stepsize.set("skip",1);
			this.stepsize.set("jump",2);
			this.xoffset = 0;
			this.yoffset = 24;
		} else if (pony == "Rarity"){
			this.stepsize.set("skip",1);
			this.stepsize.set("jump",3);
			this.xoffset = 0;
			this.yoffset = 24;
		}

		this.state="";
		this.cursprite=null;
		this.statecount=0;
		this.addEventListener(Event.ENTER_FRAME, eframe);

		this.paused = false;
	}

	public function addsprite(aspr:ASprite,name:String){
		this.asprites.set(name,aspr);
		aspr.visible = false;
		this.addChild(aspr);
		aspr.looped = this.childloop;
	}

	public function loaded(){
		this.state="stand";
		trace("New msprite loaded with "+this.asprites);
		this.asprites.get(state).visible = true;
	}

	public function newstate(nstate:String){
		asprites.get(state).visible = false;
		state=nstate;
		if (nstate=="fly" && pony=="Fluttershy") {
			this.y += 4*16;
			this.y -= 7*14-5*4;
			statecount=1;
			trace(this.y);
		} else if (nstate=="fly" && pony=="Twilight") {
			statecount=0;
			this.y -= 7*14-5*4;
		} else if (nstate=="fly") {
			this.y += 46-1;
			statecount=0;
		} else if (nstate=="super" && pony=="Rarity"){
			statecount=5;
		}
		trace(state);
		asprites.get(state).visible = true;
		asprites.get(state).reset();
		cursprite = asprites.get(state);
	}

	public function childloop(){
		trace(this.y);
		if (statecount>0){
			statecount -= 1;
		} else {
			if (game!=null)
				game.land(state);
		}
	}

	//Should probably be in gamewindow rather than here.
	public function eframe(ev:Event){
		if (cursprite==null) return;
		if (paused) return;
		if (["jump","skip","slide"].has(state)){
			if (pony=="Fluttershy") {
				if (this.asprites.get(state).framenum() > 6 && this.asprites.get(state).framenum() < 13){
					this.x += stepsize.get(state)*2;
					Uti.scrollRectScrollAdd(parent,stepsize.get(state)*2);
				}
				this.x += stepsize.get(state)*2;
				Uti.scrollRectScrollAdd(parent,stepsize.get(state)*2);
			} else if (pony=="Rarity") {
				if (this.asprites.get(state).framenum() > 0 && this.asprites.get(state).framenum() < 6){
					this.x += stepsize.get(state)*4;
					Uti.scrollRectScrollAdd(parent,stepsize.get(state)*4);
				}
			} else if (this.asprites.get(state).framenum() > 1){
				this.x += stepsize.get(state)*2;
				Uti.scrollRectScrollAdd(parent,stepsize.get(state)*2);
			}
		} else if (["back-skip","back-jump","back-slide"].has(state)){
			//Should only apply to Rarity anyway
			var truestate = state.substr(5);
			if (pony=="Fluttershy") {
				trace(truestate);
				if (this.asprites.get(state).framenum() > 6 && this.asprites.get(state).framenum() < 13){
					this.x -= stepsize.get(truestate)*2;
					Uti.scrollRectScrollAdd(parent,-stepsize.get(truestate)*2);
				}
				this.x -= stepsize.get(truestate)*2;
				Uti.scrollRectScrollAdd(parent,-stepsize.get(truestate)*2);
			} else if (pony=="Rarity") {
				if (this.asprites.get(state).framenum() > 0 && this.asprites.get(state).framenum() < 6){
					this.x -= stepsize.get(truestate)*4;
					Uti.scrollRectScrollAdd(parent,-stepsize.get(truestate)*4);
				}
			} else if (this.asprites.get(state).framenum() > 1){
				this.x += stepsize.get(truestate)*2;
				Uti.scrollRectScrollAdd(parent,stepsize.get(truestate)*2);
			}
		} else if (state.startsWith("rasuper-")) {
			var truestate = state.substr(8);
			if (this.asprites.get(state).framenum() > 0 && this.asprites.get(state).framenum() < 6){
				this.x += stepsize.get(truestate)*8;
				Uti.scrollRectScrollAdd(parent,stepsize.get(truestate)*8);
			}
			cursprite.eframe(null);
		} else if (["jumpnn","skipnn"].has(state)) {
			if (this.asprites.get(state).framenum() > 1){
				this.x += stepsize.get(state)*4;
				Uti.scrollRectScrollAdd(parent,stepsize.get(state)*4);
			} else {
				this.x += stepsize.get(state)*2;
				Uti.scrollRectScrollAdd(parent,stepsize.get(state)*2);
			}
			cursprite.eframe(null);
		} else if (["arrive"].has(state)){
			//this.x += stepsize.get("teleport")*2;
			Uti.scrollRectScrollAdd(parent,stepsize.get("teleport")*2);
		} else if (["teleport-home"].has(state)){
			Uti.scrollRectScrollAdd(parent,-this.x/Const.tilex);
		} else if (["arrive-home"].has(state)){
			Uti.scrollRectScroll(parent,0);
		} else if (["arrive-super-slide"].has(state)){
			Uti.scrollRectScrollAdd(parent,stepsize.get("slide")*2);
		} else if (["arrive-super-teleport"].has(state)){
			Uti.scrollRectScrollAdd(parent,stepsize.get("teleport")*2);
		} else if (["arrive-super-skip"].has(state)){
			Uti.scrollRectScrollAdd(parent,stepsize.get("skip")*2);
		} else if (["arrive-home"].has(state)){
		} else if (this.state=="fly" && this.pony=="Twilight"){
		} else if (this.state=="fall" && this.pony=="Twilight"){
			this.y += 2;
			if (this.asprites.get(state).framenum() > 3)
				this.y += 5;
		} else if (this.state=="fall" && this.pony=="Fluttershy"){
			this.y += 2;
			if (this.asprites.get(state).framenum() > 3)
				this.y += 5;
		} else if (this.state=="fly"){
			this.y -= 1;
		} else if (["super"].has(state)){
			//Change background alpha or something
			//ponyspecial.set("sbg",.alpha//ponyspecial.get("sbg").alpha-0.1);
		}
		cursprite.eframe(null);
		Uti.capscrollrect(parent);
	}

	public function destroy(){
		this.removeEventListener(Event.ENTER_FRAME, eframe);
	}
}

//Animated sprite
class ASprite extends Sprite {
	var fnum:Int;
	var frames:Array<Bitmap>;
	var speed:Int;
	var frametimes:Array<Int>;
	//Function to be called when looping
	public var looped:Dynamic;

	public function new(speed:Int=4,frametimes=null){
		super();
		this.fnum = 0;
		this.speed = speed;
		this.frames = new Array<Bitmap>();
		this.frametimes = frametimes;
		this.looped = null;
	}

	public function addframe(f:Dynamic){
		frames.push(f);
		addChild(f);
		if (frames.length>1) f.visible = false;
	}

	public function buildframetimes(){
		if (frametimes == null){
			frametimes = new Array<Int>();
			for (i in 0...frames.length+1) frametimes.push(i*speed);
		}
	}

	public function reset(){
		//if (frametimes.search(fnum)>0) trace(frames[frametimes.search(fnum)-1].visible);
		//trace(frametimes.search(fnum)-1);
		frames[framenum()].visible = false;
		fnum=0;
		frames[0].visible=true;
		//for (frame in frames) frame.visible = false;
	}

	public function framenum(){
		return frametimes.search(fnum)-1;
	}

	//Show last frame (used when looping)
	public function showlast(){
		frames[frametimes.index(fnum)].visible = false;
		fnum=frametimes[frametimes.length-1];
		frames[frames.length-1].visible = true;		
	}

	public function fincr(){
		fnum+=1;
	}

	public function eframe(ev:Event){
		//trace(ev);
		if (this.visible){
			fnum+=1;
			if (frametimes != null){
				if (frametimes.has(fnum)){
					if (fnum==frametimes[frametimes.length-1]) fnum = 0;
					if (fnum==0){
						//Looping
						frames[frames.length-1].visible = false;
					} else {
						frames[frametimes.index(fnum)-1].visible = false;		
					}
					//trace(fnum+" "+frametimes.index(fnum)+" "+frametimes[frametimes.length-1]);
					frames[frametimes.index(fnum)].visible = true;
					//if (frametimes.index(fnum)!=frametimes.search(fnum)) throw "foobar";
					if (fnum==0 && looped!=null) looped();//par.childloop();
				}
			}
		}
	}
}

class Floor extends Sprite {
	public var tiles:Array<String>;
	public var imgtiles:Array<Bitmap>;

	var skip:Int;
	var jump:Int;
	public var pony:String;

	var types:Array<String>;
	public var solution:Array<Int>;

	public function new(pony="Pinkie Pxie",types=null){
		super();
		this.pony = pony;
		if (pony=="Pinkie Pie"){
			this.skip = 2;
			this.jump = 3;
		} else if (pony=="Twilight"){
			this.skip = -1;
			this.jump = 7;
		} else if (pony=="Fluttershy"){
			this.skip = 1;
			this.jump = 2;
		} else if (pony=="Rarity"){
			this.skip = 1;
			this.jump = 3;
		}
		tiles = new Array<String>();
		if (types == null) this.types = ["water","rock","ice","button"];
		else this.types = types;
	}

	public function generate(){
		//Twilight generator
		if (pony=="Twilight"){
			var G = new Array<Array<Int>>();
			var buttonright = new Array<Int>();
			for (i in 0...11){
				var v = jump+2+Std.random(Const.racelen-jump-2);
				if (!buttonright.has(v+jump) && !buttonright.has(v-jump)) buttonright.push(v);
			}
			G[0]=[jump];
			for (i in 1...(Const.racelen-jump)){
				G[i] = [i+jump];
				if (!buttonright.has(i)) G[i].push(i+skip);
			}
			for (i in (Const.racelen-jump)...Const.racelen-1){
				G[i] = [Const.racelen-1];
				if (!buttonright.has(i)) G[i].push(i+skip);
			}
			G[Const.racelen-1]=[];

			for (i in 0...Const.racelen){
				if (G[i].length==2){
					if (Std.random(2)==1) G[i].reverse();
				}
			}

			var H = new Array<Array<Int>>();
			for (i in 0...Const.racelen) H[i]=[];

			var pred = new Array<Int>();
			for (i in 0...Const.racelen) pred[i]=-1;
			pred[0]=0;
			var stack = new Array<Int>();
			stack.push(0);
			while (stack.length>0){
				var v = stack.pop();
				for (u in G[v]){
					if (pred[u]==-1){
						H[v].push(u);
						pred[u] = v;
						stack.push(u);
						stack.push(v);
						break;
					}
				}
			}

			tiles.push("rock");
			for (i in 1...H.length){
				if (H[i].has(i+7) || H[i].has(Const.racelen-1)) tiles.push("rock");
				else if (H[i].length==1) tiles.push("ice");
				else tiles.push("water");
			}

			if (types.has("button")){
				for (i in buttonright){
					tiles[i-1]="button platform";
					tiles[i-1-jump]="button";
				}
			} else {
				for (i in buttonright){
					tiles[i-1]="rock";
					tiles[i-1-jump]="rock";
				}
			}

			//Off by 1 error?
			tiles[Const.racelen-1]="rock";

			for (i in 0...10) tiles.push("rock");
			for (i in 0...Const.racelen){
				trace(i+" "+G[i]+" "+pred[i]+" "+H[i]);
			}
			trace(buttonright);

			solution = new Array<Int>();
			var i = Const.racelen-1;
			while (i!=0){
				solution.push(i);
				i=pred[i];
			}
			solution.reverse();
			trace("solution:"+solution);
			//trace(G);
			//trace(H);
		//Normal generator
		} else if (pony=="Pinkie Pie" || pony=="Fluttershy" || pony=="Rarity"){
			tiles.push("rock");
			//var types = ["water","rock","button","ice"];
			//var types = ["water","rock"];
			var nonwatertypes = types.slice(1);
			var nonwatericetypes = ["rock"];
			if (types.has("button")) nonwatericetypes.push("button");
			for (i in 1...Const.racelen){
				if (tiles[tiles.length-jump]=="button") {
					tiles.push("button platform");
				} else if (["button platform","water"].has(tiles[tiles.length-(jump-skip)])) {
					var type = nonwatertypes.randitem();
					type = "ice";
					if (type=="ice" && !["rock","button"].has(tiles[tiles.length-1]))
						type = nonwatericetypes.randitem();
					tiles.push(type);
				} else if (tiles[tiles.length-(jump-skip)]=="ice" && skip==1) {
					var type = nonwatertypes.randitem();
					if (Const.debugmoreice) type = "ice";
					if (type=="ice" && !["rock","button"].has(tiles[tiles.length-1]))
						type = nonwatericetypes.randitem();
					tiles.push(type);
				} else if (tiles[tiles.length-skip]=="button"){
					var type = ["water","non water"].randitem();
					if (type=="water"){
						tiles.push("water");
					} else {
						var type = types.randitem();
						tiles.push(type);
					}
				} else if (["rock","button"].has(tiles[tiles.length-(jump-skip)])){
					var type = types.randitem();//Std.random(4);
					tiles.push(type);
				} else {
					tiles.push("rock");
				}
			}
			for (i in 0...10) tiles.push("rock");
			if (pony=="Rarity"){
				trace("Rarity level");
				trace(tiles);
			}
		}
	}

	public function drawtile(i){
			var tile = tiles[i];
			var newbm = null;
			if (tile == "rock") {
				newbm = new Bitmap(Res.images.get("cloud"));
				newbm.x=i*Const.tilex-10;
			} else if (tile == "button"){
				newbm = new Bitmap(Res.images.get("button"));
				newbm.x=i*Const.tilex-10;
			} else if (tile == "pressed button"){
				newbm = new Bitmap(Res.images.get("button-pressed"));
				newbm.x=i*Const.tilex-10;
			} else if (tile == "ice"){
				newbm = new Bitmap(Res.images.get("ice"));
				newbm.x=i*Const.tilex-10;
			}
			return newbm;
	}


	public function draw(){
		imgtiles = new Array<Bitmap>();
		for (i in 0...tiles.length){
			var newbm = drawtile(i);
			if (newbm != null)
				this.addChild(newbm);
			imgtiles.push(newbm);
		}
		this.cacheAsBitmap = true;
	}

	public function drawmaptile(i){
		var tile = tiles[i];
		var newbm = null;
		if (tile == "rock") {
			newbm = new Bitmap(Res.images.get("cloud-small"));
		} else if (tile == "button" || tile == "pressed button"){
			newbm = new Bitmap(Res.images.get("button-small"));
		} else if (tile == "ice"){
			newbm = new Bitmap(Res.images.get("spring-small"));
		}
		var rowlen = 14;
		if (newbm!=null){
			newbm.x=(i%rowlen)*22;
			newbm.y=Std.int(i/rowlen)*13;
		}
		return newbm;
	}

	public function drawmap(){
		var map = new Sprite();
		//Draw background
		var g=map.graphics;
		g.beginFill(Const.colts);
		g.drawRect(0,0,15*22,100);
		g.endFill();

		//Draw tiles
		//for (i in 0...tiles.length){
		for (i in 0...Const.racelen){
			var newbm = drawmaptile(i);
			if (newbm != null){
				map.addChild(newbm);
			}
		}
		map.cacheAsBitmap = true;
		return map;
	}

	//keys is a hack for now
	public function simulate(loc:Int,moves:Array<Int>,keys:Array<Int>){
		var simtiles = tiles.copy();
		for (i in 0...moves.length){
			while (simtiles[loc]=="ice") loc-=1;
			trace("sim:"+loc+" "+simtiles[loc]);
			if (simtiles[loc]=="water") {trace("sim:fell at"+loc);return -1;}
			if (simtiles[loc]=="button") simtiles[loc+jump]="rock";
			var ind = keys.index(moves[i]);
			if (ind==0) loc+=skip;
			else if (ind==1) loc+=jump;
			if (loc>=Const.racelen) return i;
		}
		return -1;
	}

	public function issafe(loc:Int){
		if (["rock","button","pressed button","ice"].has(tiles[loc])){
			return true;
		} else {
			return false;
		}
	}

	public function isgood(loc:Int){
		if (["rock","pressed button","button"].has(tiles[loc])){
			return true;
		} else {
			return false;
		}
	}

	public function landon(loc:Int){
		if (tiles[loc]=="button"){
			tiles[loc+jump]="rock";
			var newbm = drawtile(loc+jump);
			newbm.x=loc*Const.tilex-10;
			this.addChild(newbm);
			Tweener.addTween(newbm,{x:(loc+jump)*Const.tilex-10, time:1});
			tiles[loc]="pressed button";
			//Should remove old tile
			var newbm = drawtile(loc);
			newbm.x=loc*Const.tilex-10;
			this.addChild(newbm);
			imgtiles[loc+jump] = newbm;
		} else if (tiles[loc]=="ascender"){
			tiles[loc]="rock";
			var newbm = drawtile(loc);
			newbm.x=loc*Const.tilex-10;
			newbm.y=Const.floordiffy;
			this.addChild(newbm);
			Tweener.addTween(newbm,{y:0, time:0.5});
		}
	}

	public function turntowater(loc:Int){
		tiles[loc]=="water";
		//Should now remove the corresponding bm
	}
}

class SelectWindow extends DummyWindow {
	public var bgs:Array<Bitmap>;

	public var paused:Bool;

	public var keys:Array<Int>;
	public var curselection:Int;
	//public var selectimgs:Array<Bitmap>;
	public var selectimgs:Array<BitmapData>;
	public var selectimg:Bitmap;
	public var oldselectimg:Bitmap;
	public var aimode:Bool;
	public var ponies:Array<String>;

	public var pony:String;
	//A function
	public var allselected:Dynamic;

	public var selecttimer:Timer;

	public function new(ponies,keys,allselected){
		super();
		MemoryTracker.track(this,"Select Window");
		this.ponies = ponies;
		this.pony = "";
		this.keys = keys;
		this.allselected = allselected;
		this.selecttimer = null;

		this.curselection=0;
		this.selectimgs = new Array<BitmapData>();
		if (keys != null) {	
			for (pony in ponies){
				//this.selectimgs.push(new Bitmap(Res.images.get("select "+pony)));
				this.selectimgs.push(Res.images.get("select "+pony));
			}
			//dangerous
			flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
		} else {
			//A.I mode
			//this.selectimgs.push(new Bitmap(Res.images.get("select AI")));
			this.selectimgs.push(Res.images.get("select AI"));
		}
		this.selectimg=new Bitmap(this.selectimgs[this.curselection]);
		this.addChild(this.selectimg);
		this.oldselectimg=new Bitmap(this.selectimgs[this.curselection]);
		this.addChild(this.oldselectimg);

		var rect:Rectangle = new Rectangle(0, 0, 400, 100);
		this.scrollRect = rect;
	}

	override public function destroy(){
		flash.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
	}

	function kdown(ev:KeyboardEvent){
		if (aimode) return;
		if (paused) return;
		trace("keyCode "+ev.keyCode);
		if (ev.keyCode==keys[0]){
			//Already selected
			if (pony!="") return;
			Tweener.removeTweens(oldselectimg);
			Tweener.removeTweens(selectimg);
			curselection=(curselection+1)%ponies.length;
			this.oldselectimg.bitmapData = this.selectimg.bitmapData;
			this.oldselectimg.y = 0;
			this.selectimg.bitmapData = this.selectimgs[this.curselection];
			this.selectimg.y = 100;
			Tweener.addTween(oldselectimg,{y:-100, time:1});
			Tweener.addTween(selectimg,{y:0, time:1});
		} else if (ev.keyCode==keys[1]){
			//Already selected
			if (pony!="") return;
			pony = Const.ponyname.get(ponies[curselection]);
			if (selecttimer!=null) selecttimer.stop();
			var whiteover = new Sprite();
			var g = whiteover.graphics;
			g.beginFill(0xffffff);
			g.drawRect(0,0,400,100);
			g.endFill();
			this.addChild(whiteover);
			Tweener.addTween(whiteover,{alpha:0, time:1, onComplete:allselected});
		}
	}

	public function setautoselecttimer(){
		if (selecttimer != null){
			selecttimer.reset();
		} else {
			if (Const.debugmultiplayer) selecttimer = new Timer(100,1);
			else selecttimer = new Timer(3000,1);
			selecttimer.addEventListener("timer",autoselect);
		}
		selecttimer.start();
	}

	function autoselect (ev:Event) {
		if (Const.debugponies) pony=Const.ponyname.get(Const.debugpony);
		else pony=Const.ponyname.get(ponies.randitem());
		aimode=true;
		allselected();
	}
}

//MovieClip with a destroy function (because of memory management/garbage collection problems)
class DummyWindow extends MovieClip {
	public function new(){
		super();
	}
	public function destroy(){
	}
}

class GameWindow extends DummyWindow {
	public var pp:MSprite;
	public var floor:Floor;
	public var pploc:Int;
	public var lastsafe:Int;

	public var starttime:Int;
	public var finishtime:Int;
	public var timertf:TextField;
	public var timertimer:Timer;
	public var paused:Bool;

	public var bgs:Array<Bitmap>;
	//public var bganimlayer:Sprite;
	public var bgdepth:Int;
	public var bganims:Array<ASprite>;
	public var keys:Array<Int>;
	public var heldkey:Bool;

	public var aimode:Bool;
	public var aidiff:Int;
	public var aitimer:Timer;

	public var pony:String;
	public var levelnum:Int;
	public var ponyspecial:Hash<Dynamic>;
	//Achievements
	public var ach:Hash<Dynamic>;

	//Cloud colouring
	public var ccmode:Bool;
	public var ccarray:Array<String>;
	public var ccpointer:Int;
	public var cclayer:Sprite;
	public var ccsprites:Array<Sprite>;
	public var ccpointerspr:Sprite;

	public var nextmoves:Array<String>;
	public var nextmove:String;

	public var bgtimer:Timer;

	public function new(pony,keys,types,levelnum=0,aidiff=10){
		super();
		MemoryTracker.track(this,"Game Window");
		this.pony = pony;
		this.keys = keys;
	  this.ponyspecial = new Hash<Dynamic>();
		//Should read from input or data
	  this.ach = new Hash<Dynamic>();

		this.levelnum = levelnum;
		this.ccmode = false;

		this.nextmoves = [];
		this.nextmove = "skip";

		pp = new MSprite(this,pony);
		var files = Const.files;
		//var states = ["stand","jump","skip","slide","fall","fly","win","teleport","arrive",];
		var states = ["stand","jump","skip","slide","fall","fly","win"];
		//var standtime = [10,1,1,1,1,1,20,1,1,1,1,1,20,1,1,20];
		for (file in files){
			var prefix:String = Const.img+file[0];
			var name:String = file[1];
			var len:Int = file[2];
			var speed:Int = file[3];
			var frametimes:Array<Int> = null;
			var pabbr = Const.ponyabbr.get(pony);
			//if (pabbr=="ts" && file[0]=="pp-"
			if (!name.startsWith(pabbr+"-")) continue;
			
			if (file.length>4) {
				frametimes = file[4].copy();
				for (i in 1...frametimes.length) frametimes[i]+=frametimes[i-1];
				for (i in 0...frametimes.length) frametimes[i]*=speed;
			}
			var asprite = new ASprite(speed,frametimes);
			for (i in 0...len){
				var newbm = new Bitmap(Res.images.get(prefix+i+".gif"));
				newbm.cacheAsBitmap = true;
				asprite.addframe(newbm);
			}
			asprite.buildframetimes();
			//Hack. Should do this properly
			if (name=="fs-skip") name="fs-jump";
			if (name=="fs-hop") name="fs-skip";
			trace(name.substr(3));
			if (states.has(name.substr(3))) states.remove(name.substr(3));
			pp.addsprite(asprite,name.substr(3));
		}
		//Load missing states
		trace("All states: "+states);
		for (state in states){
			//Really slow and wrong
			var asprite = Uti.loadasprite("pp-"+state,1);
			trace("Loading missing state:pp-"+state);
			pp.addsprite(asprite,state);
		}

		pp.y=170+pp.yoffset;
		pp.loaded();

		this.bgs = new Array<Bitmap>();
		var bgfile = "bg3";
		if (levelnum==1) bgfile = "bg5";
		else if (levelnum==2) bgfile = "bg6";
		else if (levelnum==3) bgfile = "bg7";
		else if (levelnum==4) bgfile = "bg4";
		if (Const.debugchickenbg) bgfile="bg3";

		var bgfiles = ["bg4","bg5","bg6"];

		for (i in 0...3){
			var newbm = new Bitmap(Res.images.get(bgfile));
			trace(newbm.width+" "+newbm.height);
			//var newbm = new Bitmap(Res.images.get(bgfiles[i]));
			newbm.cacheAsBitmap = true;
			this.addChild(newbm);
			this.bgs.push(newbm);
			//newbm.x=Const.bgwidth*i;
			newbm.x=newbm.width*i;
			newbm.y=360-newbm.height;
			//newbm.y=300-newbm.height;
			if (bgfile=="bg7") newbm.y=330-newbm.height;
		}

		//var types = null;
		//if (levelnum==1) types = ["water","rock"];
		floor = new Floor(pony,types);
		floor.generate();
		trace(floor.tiles);
		floor.draw();
		floor.y=pp.y+90-pp.yoffset;
		floor.x=Const.floorxoffset;
		this.addChild(floor);
		if (pony=="Fluttershy" && Data.supermode){
			ponyspecial.set("firstfloor",floor);
			floor = new Floor(pony,["water","rock"]);
			floor.generate();
			trace(floor.tiles);
			floor.draw();
			floor.y=pp.y+40-pp.yoffset;
			floor.x=Const.floorxoffset;
			this.addChild(floor);
			ponyspecial.set("secondfloor",floor);
			ponyspecial.set("curfloor",true);
			ponyspecial.set("secondfloorenabled",false);
			ponyspecial.set("lastfall",-1);
			floor.visible=false;
			floor=cast ponyspecial.get("firstfloor");
		}

		this.addChild(pp);
		pp.x += pp.xoffset;
		var rect:Rectangle = new Rectangle(0, 0, 400, 100);
		this.scrollRect = rect;
		var tmp=this;
		Tweener.addTween(rect,{y:200,time:1,onUpdate:function(){
				tmp.scrollRect = rect;}});

		pploc = 0;
		lastsafe = 0;
		this.ponyspecial.set("nofall", 0);
		this.ponyspecial.set("firstsuper", true);
		this.ponyspecial.set("queue", new Array<Int>());
		this.ponyspecial.set("queuesuper", false);
		this.ach.set("nofall",1);
		this.ponyspecial.set("undo", new Array<Int>());
		this.ponyspecial.set("teleporthome", false);

		this.ponyspecial.set("rasuper", false);

		//this.ponyspecial.get("map")
		var map = floor.drawmap();
		this.addChild(map);
		//map.scaleX=0.8;
		//map.scaleY=0.8;
		map.y=pp.y+30-pp.yoffset;
		map.x=40;
		map.visible=false;
		this.ponyspecial.set("map",map);
		var maptimer = new Timer(1000,1);
		maptimer.addEventListener("timer",callback(this.special,"scry on"));
		if (pony=="Twilight")	maptimer.start();
		this.ponyspecial.set("maptimer",maptimer);

		//Non-super pre-set gems
		if (pony=="Rarity") {
			//Should start at +2 but need to fix scrolling...
			ccpointer = Const.racelen+1;
			cclayer = new Sprite();
			this.addChild(cclayer);
			ccarray = new Array<String>();
			ccsprites = new Array<Sprite>();

			this.addEventListener(Event.ENTER_FRAME, cceframe);
			
			//aimode not yet defined...
			trace(Data.supermode);
			if (!Data.supermode || keys==null) {
				ccmode=true;
				ccfill();
			}
		}

		starttime = flash.Lib.getTimer();
		finishtime = -1;
		timertf = Const.textfield("0",
															"mlp",
															Const.colfs,
															Const.colfsout);
		timertf.x = 400-100;

		timertimer = new Timer(1000);
		timertimer.addEventListener("timer",updatetimer);
		timertimer.start();

		heldkey = false;
		aimode = false;
		if (keys != null) {
			//dangerous
			flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
			flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, this.kup);
		} else {
			//A.I mode
			aimode = true;
			this.aidiff = aidiff;
			var time = Math.max(100,1200-aidiff*100);
			aitimer = new Timer(time);
			aitimer.addEventListener("timer",aimove);
		}

		pp.newstate("stand");
		this.paused = true;

		if (pony=="Rarity"){
			getnextmoves();
			nextmove=nextmoves.randitem();
			pp.newstate("stand-"+nextmove);
		}

		//bganimlayer = new Sprite();
		//this.addChild(bganimlayer);
		bganims = new Array<ASprite>();
		bgdepth=3;
		//Hack
		if (pony=="Rarity") bgdepth=4;
		if (Const.debugbganim){
			var bganim = Uti.loadasprite("tank-bg",1);
			bganim.x = 300;
			bganim.y = 170+30;
			bganim.eframe(null);
			this.addChild(bganim);
			Tweener.addTween(bganim,{x:0, time:10, transition:"linear", onUpdate:function(){bganim.eframe(null);}});
			//Needs to be above bgs but below pp and floor
			this.setChildIndex(bganim,this.numChildren-bgdepth);
		}

		bgtimer = new Timer(1000);
		bgtimer.addEventListener("timer",bganimtick);
		bgtimer.start();
		this.addEventListener(Event.ENTER_FRAME, bgeframe);
	}

	public function bganimtick(ev:Event){
		//Remove existing animations
		for (bganim in bganims){
			if (bganim.x < this.scrollRect.x-Const.bgx){
				this.removeChild(bganim);
				bganims.remove(bganim);
			}
		}
		//Add new animations
		if (bganims.length < Data.maxbg){
			if (Std.random(10)==0){
				//var bgchar = ["derpy-fly-","rd-bg-zoom-","pp-copter-"].randitem();
				var bgchar = ["derpy-bg","rd-bg","tank-bg","spitfire-bg"].randitem();
				var bganim = Uti.loadasprite(bgchar,1);
				bganim.x = this.scrollRect.x+Const.bgx+400;
				bganim.y = 170+30;
				bganim.eframe(null);
				this.addChild(bganim);
				//Tweener.addTween(bganim,{x:this.scrollRect.x-Const.bgx, time:10, transition:"linear", onUpdate:function(){bganim.eframe(null);}});
				//Needs to be above bgs but below pp and floor
				this.setChildIndex(bganim,this.numChildren-bgdepth);
				bganims.push(bganim);
			}
		}
	}

	public function bgeframe(ev:Event){
		for (bganim in bganims){
			bganim.x -= Const.bgmovex;
			bganim.eframe(null);
		}
	}

	override public function destroy(){
		trace("destroying gamewindow");
		flash.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.kdown);
		flash.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, this.kup);
		var maptimer=ponyspecial.get("maptimer");
		if (maptimer!=null)
			maptimer.removeEventListener("timer",callback(this.special,"scry on"));
		this.removeEventListener(Event.ENTER_FRAME, cceframe);
		if (timertimer!=null){
			timertimer.stop();
			timertimer.removeEventListener("timer",updatetimer);
		}
		if (aitimer!=null){
			aitimer.stop();
			aitimer.removeEventListener("timer",aimove);
		}
		this.removeEventListener(Event.ENTER_FRAME, bgeframe);
		if (bgtimer!=null){
			bgtimer.stop();
			bgtimer.removeEventListener("timer",bganimtick);
		}
		pp.destroy();
		trace("destroyed gamewindow");
		//starttimer.removeEventListener("timer",readysetgo);
		//endtimer.removeEventListener("timer",checkgameend);
	}

	public function land(state){
		trace(pony+":"+state);
		if (state=="fall"){
			if (pony=="Rarity") {
				special("undofallpop");
				//New col flipping method
				//Added because of problem with A.I.
				if (floor.tiles[pploc]!="button platform") special("takegem");
			} else if (pony=="Fluttershy" && special("secondfloorfall")){
				trace("fell from top floor");
				pp.y+=Const.floordiffy-14*2-5*10;
				pp.newstate("stand");
				floor.landon(pploc);
				//We'd also need to record the lastsafefloor in the case
				return;
			}
			pploc = lastsafe;
			pp.x = pploc*Const.tilex+pp.xoffset;
			//Uti.scrollRectScroll(this,pp.x-pp.xoffset);
			var rect = this.scrollRect;
			rect.x = pp.x-pp.xoffset;
			this.scrollRect = rect;
			//if (pp.pony=="Twilight") pp.y -= 7*13-4*3+1;
			pp.newstate("fly");
		} else if (state.startsWith("back-")) {
			//Currently incompatible with Twilight banking moves (e.g., would break if everypony had banked moves)
			if (state=="back-slide") {
				var move = special("undopop");
				trace("undo "+move);
				if (move != null){
					pploc -= pp.stepsize.get(move);
					var nofall = special("nofall");
					Res.sounds.get("jump2").play();
					trace("back-"+move+nofall);
					pp.newstate("back-"+move+nofall);
				} else {
					pp.newstate("stand");
				}
				if (pp.state=="stand" && pony=="Rarity") {
					getnextmoves();
					nextmove=nextmoves.randitem();
					pp.newstate("stand-"+nextmove);
				}
			} else {
				getnextmoves();
				if (nextmoves.length==1) nextmove=nextmoves[0];
				else {
					if (nextmove==nextmoves[0]) nextmove=nextmoves[1];
					else nextmove=nextmoves[0];
				}
				pp.newstate("stand-"+nextmove);
			}
		} else if (state.startsWith("arrive-super") || state.startsWith("rasuper") || ["jump","skip","jumpnn","skipnn","slide","arrive","arrive-home"].has(state)){
			if (floor.tiles[pploc]=="button") achieve("button_press");
			floor.landon(pploc);
			trace(pony+" landed on "+floor.tiles[pploc]);
			if (pploc>=Const.racelen){
				pp.newstate("win");
				timertimer.stop();
				finishtime = (flash.Lib.getTimer()-starttime);
				updatetimer(null);
			} else if (floor.tiles[pploc]=="water" || floor.tiles[pploc]=="button platform") {
				special("yesfall");
				achieve("fall");
				
				pp.newstate("fall");
			} else if (floor.tiles[pploc]=="ice") {
				ponyspecial.set("nofall",ponyspecial.get("nofall")+1);
				if (pony=="Rarity") special("takegem");
				pploc += pp.stepsize.get("slide");
				special("undoadd","slide");
				var queuesuper = special("queuesuper");
				if (queuesuper!="") {
					pp.x+=Const.tilex*pp.stepsize.get("slide");
				}
				var rasuper = special("ra-super");
				pp.newstate(rasuper+queuesuper+"slide");
			} else {
				//Should add to nofall here and check if we should activate super.
				ponyspecial.set("nofall",ponyspecial.get("nofall")+1);
				if (special("nofall")=="super"){
					//Pinkie super
					var sbg = new Bitmap(Res.images.get("superbg")); //Uti.rect(400,100);
					sbg.x=pp.x;
					sbg.y=pp.y;
					var oldx=scrollRect.x;
					Uti.scrollRectScrollAdd(this,-200+pp.width/2);
					sbg.x=this.scrollRect.x;
					sbg.y=this.scrollRect.y;
					var par=this;
					var rect=this.scrollRect;
					Tweener.addTween(rect,{x:oldx,delay:1,time:1,onUpdate:function(){par.scrollRect=rect;}});
					Tweener.addTween(sbg,{alpha:0,delay:1,time:1,transition:"easeInCubic",onComplete:function(){par.removeChild(sbg);}});
					this.addChild(sbg);
					//May conflict with bganim
					this.setChildIndex(sbg,this.numChildren-3);

					Res.sounds.get("ppsuper").play();
					pp.newstate("super");
					return;
				}
				//special("queuefinish");

				//Need to distinguish
				if (!ponyspecial.get("queuesuper") && pony=="Twilight"){
				var finished = special("queuefinish");
				if (finished) {
					//Twilight super
					var sbg = new Bitmap(Res.images.get("superbg")); //Uti.rect(400,100);
					sbg.x=pp.x;
					sbg.y=pp.y;
					var oldx=scrollRect.x;
					Uti.scrollRectScrollAdd(this,-200+pp.width/2);
					sbg.x=this.scrollRect.x;
					sbg.y=this.scrollRect.y;
					var par=this;
					var rect=this.scrollRect;
					Tweener.addTween(rect,{x:oldx,delay:1,time:1,onUpdate:function(){par.scrollRect=rect;}});
					Tweener.addTween(sbg,{alpha:0,delay:1,time:1,transition:"easeInCubic",onComplete:function(){par.removeChild(sbg);}});
					this.addChild(sbg);
					//May conflict with bganim
					this.setChildIndex(sbg,this.numChildren-3);

					Res.sounds.get("tssuper").play();
					pp.newstate("super");
					ponyspecial.set("queuesuper", true);
					return;
				}
				}
				if (special("moveup")){
					//Tween moving up animation
					trace(pploc+":"+floor.tiles[pploc]);
					floor.landon(pploc);
				}
				var keycode = special("queuepop");
				pp.newstate("stand");
				if (keycode!=-1) keypressed(keycode,false);
				if (pp.state=="stand") special("scry start");

				var rasuper = special("ra-super");
				if (rasuper!=""){
					var move = special("ra-queuepop");
					nextmove=move;
					special("takegem");
					pploc += pp.stepsize.get(move);
					var nofall = special("nofall");
					//To fix
					//Might be OK if Rarity forward is jump1 and backward is jump2
					Res.sounds.get("jump1").play();
					pp.newstate("rasuper-"+move+nofall);
					special("undoadd",move);
				}

				if (pp.state=="stand" && pony=="Rarity") {
					getnextmoves();
					nextmove=nextmoves.randitem();
					pp.newstate("stand-"+nextmove);
				}

				//dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,keycode));
			}
			//pp.newstate("jump");
			//trace(pp.x+" "+this.bgs[0].x);
			
			//if (pp.x>this.bgs[0].x+Const.bgwidth*2){
			if (pp.x>this.bgs[0].x+bgs[0].width*2){
				var bg:Bitmap=this.bgs.shift();
				trace(this.bgs.length-1);
				//bg.x = this.bgs[Std.int(this.bgs.length-1)].x+Const.bgwidth;
				bg.x = this.bgs[Std.int(this.bgs.length-1)].x+bgs[0].width;
				this.bgs.push(bg);
			}
			/*} else if (state=="fly"){
			pp.newstate("fly-stop");*/
		} else if (state=="super") {
			if (pony=="Twilight"){
				//Twilight super
				var keycode = special("queuepop");
				pp.newstate("stand");
				if (keycode!=-1) keypressed(keycode);
			} else if (pony=="Rarity"){
				var move = special("ra-queuepop");
				nextmove=move;
				special("takegem");
				pploc += pp.stepsize.get(move);
				var nofall = special("nofall");
				//To fix
				//Might be OK if Rarity forward is jump1 and backward is jump2
				Res.sounds.get("jump1").play();
				pp.newstate("rasuper-"+move+nofall);
				special("undoadd",move);
			} else {
				pp.newstate("stand");
			}
		} else if (state=="teleport"){
			if (!special("teleporthome") || ponyspecial.get("queuesuper")){
				pp.x += Const.tilex*pp.stepsize.get("teleport");
				pploc += pp.stepsize.get("teleport");
				pp.newstate("arrive");
			} else {
				//But now missing scrolling animation
				lastsafe = 0;
				pploc = 0;
				pp.x = pploc*Const.tilex+pp.xoffset;
				//Clear queue
				special("yesfall");
				pp.newstate("arrive-home");
			}
		} else if (state=="teleport-home"){
			pploc = 0;
			pp.x = pploc*Const.tilex+pp.xoffset;
			special("yesfall");
			pp.newstate("arrive-home");
		} else if (state=="win"){

		} else if (state=="fly" && pony=="Fluttershy") {
				if (special("enablesecondfloor")){
					//Fluttershy super
					trace("enabling second floor");
					var sbg = new Bitmap(Res.images.get("superbg")); //Uti.rect(400,100);
					sbg.x=pp.x;
					sbg.y=pp.y;
					var oldx=scrollRect.x;
					Uti.scrollRectScrollAdd(this,-200+pp.width/2);
					sbg.x=this.scrollRect.x;
					sbg.y=this.scrollRect.y;
					var par=this;
					var rect=this.scrollRect;
					Tweener.addTween(rect,{x:oldx,delay:1,time:1,onUpdate:function(){par.scrollRect=rect;}});
					Tweener.addTween(sbg,{alpha:0,delay:1,time:1,transition:"easeInCubic",onComplete:function(){par.removeChild(sbg);}});
					this.addChild(sbg);
					//May conflict with bganim
					this.setChildIndex(sbg,this.numChildren-3);
					Res.sounds.get("fssuper").play();
					pp.newstate("super");
				} else {
					pp.newstate("stand");
				}
		} else if ((state.startsWith("stand") || state=="fly") && pony=="Rarity") {
			if (state=="fly") getnextmoves();
			if (nextmoves.length==1) nextmove=nextmoves[0];
			else {
				if (nextmove==nextmoves[0]) nextmove=nextmoves[1];
				else nextmove=nextmoves[0];
			}
			pp.newstate("stand-"+nextmove);
		} else {
			pp.newstate("stand");
		}
		if (aimode) aitimer.start();
	}

	public function togglepause(){
		if (paused){
			paused = false;
			if (aimode)	aitimer.start();
		} else {
			paused = true;
			if (aimode)	aitimer.stop();
		}
		pp.paused = paused;
	}

	public function updatetimer(ev:Event){
		//timer.text = "time:"+(Std.int((flash.Lib.getTimer()-starttime)/1000));
		timertf.text = "time:"+((flash.Lib.getTimer()-starttime)/1000);
	}

	public function racestart(){
		if (pony=="Rarity" && Data.supermode && !aimode){
			ccstart();
		}
	}

	public function changeaidiff(newdiff){
		if (!aimode) return;
		if (aidiff==newdiff) return;
		aidiff=newdiff;
		aitimer.stop();
		aitimer.removeEventListener("timer",aimove);
		var time = Math.max(100,1200-aidiff*100);
		aitimer = new Timer(time);
		aitimer.addEventListener("timer",aimove);
		aimove(null);
	}

	public function aimove(ev:Event){
		if (paused) return;
		if (ccmode) return;
		if (["stand","stand-jump","stand-skip"].has(pp.state)){
			var moves = [];
			if (pony=="Pinkie Pie"){
				moves = ["skip","jump"];
			} else if (pony=="Fluttershy"){
				moves = ["skip","jump"];
			} else if (pony=="Twilight"){
				moves = ["skip","teleport"];
			} else if (pony=="Rarity"){
				moves = ["skip","jump"];
			}

			//var move = "skip";			
			var move = null;
			if (pony=="Twilight"){
				var next = floor.solution.shift();
				trace(pploc+" "+next);
				if (next > pploc) move="teleport";
				else move="skip";
				if (next == null) move="teleport";
				//variable reuse
				while (floor.tiles[next]=="ice") {
					next = floor.solution.shift();
				}
			} else if (pony=="Rarity") {
				getnextmoves();
				var nonempty = [];
				for (mov in moves){
					if (ccarray[pploc+pp.stepsize.get(mov)]=="light" || ccarray[pploc+pp.stepsize.get(mov)]=="dark")
						nonempty.push(mov);
				}

				//trace(nextmoves);
				trace("non-empty "+nonempty);
				trace("pploc "+pploc);
				if (nonempty.length==0){
					//Backward
					move = special("undopop");
					if (move!=null) move="back-"+move;
					//Shouldn't really happen
					else return;
				} else {
					var safes=new Array<String>();
					var goods=new Array<String>();
					for (mov in nextmoves){
						if (floor.issafe(pploc+pp.stepsize.get(mov))) safes.push(mov);
						if (floor.isgood(pploc+pp.stepsize.get(mov))) goods.push(mov);
					}
					//temporary intelligence
					var int = Std.random(aidiff);
					trace("int "+int);
					if (int==0) move = nextmoves.randitem();
					else if (int<3) {
						if (safes.length>0)	move = safes.randitem();
						else move = nextmoves.randitem();
					}	else {
						if (goods.length>0) move = goods.randitem();
						else if (safes.length>0) move = safes.randitem();
						else if (nonempty.length==1) move = "back";
						else move = nextmoves.randitem();
					}
					//Forward

					//move=nextmoves.randitem();
					if (move=="back"){
						move = special("undopop");
						if (move!=null) move="back-"+move;
					} else {
						special("undoadd",move);
					}
				}
			} else {
				//Greedily lookahead
				//var aidiff=10;
				var safes=new Array<String>();
				var goods=new Array<String>();
				for (mov in moves){
					if (floor.issafe(pploc+pp.stepsize.get(mov))) safes.push(mov);
					if (floor.isgood(pploc+pp.stepsize.get(mov))) goods.push(mov);
				}
				//temporary intelligence
				var int = Std.random(aidiff);
				if (int==0 || safes.length==0) move = moves.randitem();
				else if (int<3 || goods.length==0) move = safes.randitem();
				else move = goods.randitem();
				/*for (i in 0...aidiff){
				var moveind = Std.random(2);
				move = moves[moveind];
				if (floor.issafe(pploc+pp.stepsize.get(move))){
					if (floor.isgood(pploc+pp.stepsize.get(move)) || aidiff<3) break;
				}
   			}*/
			}
			if (pony=="Rarity") special("takegem");
			special("scry off");
			trace("ai chosen move "+move);
			if (move.startsWith("back-")){
				move = move.substr(5);
				pploc -= pp.stepsize.get(move);
				var nofall = special("nofall");
				Res.sounds.get("jump2").play();
				trace("back-"+move+nofall);
				pp.newstate("back-"+move+nofall);
			} else {
				lastsafe = pploc;

				if (move!="teleport")
					pploc += pp.stepsize.get(move);
				if (move=="skip") 
					Res.sounds.get("jump2").play();
				else
					Res.sounds.get("jump1").play();
				trace("ai:"+move);
				var nofall = special("nofall");
				pp.newstate(move+nofall);
				aitimer.stop();
			}
		}
	}

	function kdown(ev:KeyboardEvent){
		if (aimode) return;
		if (paused) return;
		if (heldkey) return;
		trace("keyCode "+ev.keyCode);
		trace(keys);
		if (!keys.has(ev.keyCode)) return;
		special("scry off");
		if (special("queuesuper")!="") return;
		heldkey=true;
		keypressed(ev.keyCode,true);
	}

	function keypressed(keycode,realkey=false){
		trace("received keyCode");
		if (keycode==keys[3] && ccmode) {
			//Randomly fill cols
			ccfill(true);
			//Uti.scrollRectScrollAdd(this,Const.tilex*5);
		} else if (keycode==keys[0] && ccmode) {
			ccarray[ccpointer]="dark";
			var circle = Uti.gem("dark");//Uti.circle(20,0);
			circle.x=Const.tilex+ccpointer*Const.tilex;
			circle.y=260;
			ccsprites[ccpointer]=circle;
			cclayer.addChild(circle);
			ccpointer-=1;
			Uti.scrollRectScrollAdd(this,-Const.tilex);
			ccpointerspr.x=(ccpointer+1)*Const.tilex;
			if (ccpointer<0) ccend(true);
		} else if (keycode==keys[1] && ccmode){
			ccarray[ccpointer]="light";
			var circle = Uti.gem("light");//Uti.circle(20,Const.colts);
			circle.x=Const.tilex+ccpointer*Const.tilex;
			circle.y=260;
			ccsprites[ccpointer]=circle;
			cclayer.addChild(circle);
			ccpointer-=1;
			Uti.scrollRectScrollAdd(this,-Const.tilex);
			ccpointerspr.x=(ccpointer+1)*Const.tilex;
			if (ccpointer<0) ccend(true);
		} else if (keycode==keys[1] && pony == "Rarity"){
			//Forward
			if (["stand","stand-skip","stand-jump"].has(pp.state)){
				lastsafe = pploc;
				var move = nextmove;
				special("takegem");

				pploc += pp.stepsize.get(move);
				var nofall = special("nofall");
				//To fix
				Res.sounds.get("jump1").play();
				pp.newstate(move+nofall);
				special("undoadd",move);
			} else if (!["win"].has(pp.state)){
				special("queueadd",keycode);
			}
		} else if (keycode==keys[0] && pony == "Rarity"){
			//Backward
			if (["stand","stand-skip","stand-jump"].has(pp.state)){
				var move = special("undopop");
				trace("undo "+move);
				if (move != null){
					special("takegem");
					pploc -= pp.stepsize.get(move);
					var nofall = special("nofall");
					Res.sounds.get("jump2").play();
					trace("back-"+move+nofall);
					pp.newstate("back-"+move+nofall);
				}
			}
		} else if (keycode==keys[1] && (Const.debugkeys
							 || pony != "Twilight")){
			if (["stand"].has(pp.state)){
				lastsafe = pploc;
				pploc += pp.stepsize.get("jump");
				var nofall = special("nofall");
				Res.sounds.get("jump1").play();
				pp.newstate("jump"+nofall);
			} else if (!["win"].has(pp.state)){
				special("queueadd",keycode);
			}
		} else if (keycode==keys[0]){
			if (["stand"].has(pp.state)){
				lastsafe = pploc;
				Res.sounds.get("jump2").play();

				pploc += pp.stepsize.get("skip");
				var nofall = special("nofall");
				var queuesuper = special("queuesuper");
				if (queuesuper!="") {
					pp.x+=Const.tilex*pp.stepsize.get("skip");
				}
				pp.newstate(queuesuper+"skip"+nofall);
			} else if (!["win"].has(pp.state)){
				special("queueadd",keycode);
			}
		} else if (keycode==keys[3] && pony=="Twilight"){
			//Teleport to beginning
			if (["stand"].has(pp.state)){
				lastsafe = 0;
				Res.sounds.get("jump2").play();

				//pploc += pp.stepsize.get("teleport");
				pp.newstate("teleport-home");
			}
		} else if (keycode==keys[3]){
			//Cloud colouring
			ccmode = true;
			trace("entering ccmode");
			ccpointerspr = new Sprite();
			var gem = Uti.gem("dark");
			gem.x=10;
			gem.y=210;
			ccpointerspr.addChild(gem);
			var gem = Uti.gem("light");
			gem.x=-10;
			gem.y=210;
			ccpointerspr.addChild(gem);

			cclayer.addChild(ccpointerspr);
			ccpointerspr.x=(ccpointer+1)*Const.tilex;
			Uti.scrollRectScrollAdd(this,(Const.racelen-2)*Const.tilex);
		} else if ((keycode==keys[2] && Const.debugkeys)
							 || (!Const.debugkeys && keycode==keys[1] && pony=="Twilight")){
			//Teleport
			if (["stand"].has(pp.state)){
				lastsafe = pploc;
				Res.sounds.get("jump2").play();

				//pploc += pp.stepsize.get("teleport");
				var queuesuper = special("queuesuper");
				if (queuesuper!="") {
					pploc += pp.stepsize.get("teleport");
					pp.x+=Const.tilex*pp.stepsize.get("teleport");
				}
				if (realkey) special("teleporthome",true);
				pp.newstate(queuesuper+"teleport");
			} else if (!["win"].has(pp.state)){
				special("queueadd",keycode);
			}
		}
	}

	function kup(ev:KeyboardEvent){
		heldkey=false;
		if (aimode) return;
		if (paused) return;
		if (!keys.has(ev.keyCode)) return;
		if (special("queuesuper")!="") return;
		if (ev.keyCode==keys[1]) special("teleporthome",false);
	}

	public function ended(){
		return (pp.state == "win");
	}

	public function ccfill(moverect=false){
		while (ccpointer>=0){
			var val = ["dark","light"].randitem();
			ccarray[ccpointer]=val;
			var circle = Uti.gem(val);//Uti.circle(20,col);
			circle.x=Const.tilex+ccpointer*Const.tilex;
			circle.y=260;
			ccsprites[ccpointer]=circle;
			cclayer.addChild(circle);
			ccpointer-=1;
			if (moverect) Uti.scrollRectScrollAdd(this,-Const.tilex);
		}
		ccend(moverect);
		//this.addEventListener(Event.ENTER_FRAME, cceframe);
	}

	public function ccstart(){
		ccmode=true;
		ccpointerspr = new Sprite();
		var gem = Uti.gem("dark");
		gem.x=10;
		gem.y=210;
		ccpointerspr.addChild(gem);
		var gem = Uti.gem("light");
		gem.x=-10;
		gem.y=210;
		ccpointerspr.addChild(gem);

		cclayer.addChild(ccpointerspr);
		ccpointerspr.x=(ccpointer+1)*Const.tilex;
		Uti.scrollRectScrollAdd(this,(Const.racelen-2)*Const.tilex);
	}

	public function cceframe(ev:Event){
		for (gem in ccsprites){
			if (gem!=null && gem.numChildren==2){
				(cast gem.getChildAt(0)).eframe(null);
			}
		}
		if (ccpointerspr!=null){
			(cast (cast ccpointerspr.getChildAt(0)).getChildAt(0)).eframe(null);
			(cast (cast ccpointerspr.getChildAt(1)).getChildAt(0)).eframe(null);
		}
	}

	public function ccend(moverect=false) {
		ccmode=false;
		if (moverect) Uti.scrollRectScrollAdd(this,Const.tilex*3);
		if (Data.supermode){
			var allmoves = ccsim();
			trace(allmoves);
			if (allmoves.length>0){
				special("ra-set-super",allmoves);
				trace("Rarity super");
				//Rarity super
				var sbg = new Bitmap(Res.images.get("superbg")); //Uti.rect(400,100);
				sbg.x=pp.x;
				sbg.y=pp.y;
				var oldx=scrollRect.x;
				Uti.scrollRectScrollAdd(this,-200+pp.width/2);
				sbg.x=this.scrollRect.x;
				sbg.y=this.scrollRect.y;
				var par=this;
				var rect=this.scrollRect;
				Tweener.addTween(rect,{x:oldx,delay:1,time:1,onUpdate:function(){par.scrollRect=rect;}});
				Tweener.addTween(sbg,{alpha:0,delay:1,time:1,transition:"easeInCubic",onComplete:function(){par.removeChild(sbg);}});
				this.addChild(sbg);
				//May conflict with bganim
				this.setChildIndex(sbg,this.numChildren-4);
				Res.sounds.get("rasuper").play();
				pp.newstate("super");
			}
		}
		getnextmoves();
	}

	public function ccsim(){
		//Simulate random path
		//Changes pploc! Needs to be reset afterwards
		var allmoves=[];
		var origccarray = ccarray.copy();
		while (true){
			//Doesn't actually take gems! This is bad.
			//Fixed (directly changing ccarray)
			getnextmoves();
			nextmove=nextmoves.randitem();
			ccarray[pploc]="none";
			pploc+=pp.stepsize.get(nextmove);
			if (!floor.issafe(pploc) && floor.tiles[pploc-pp.stepsize.get(nextmove)]!="button"){
				trace("Location "+pploc+" is unsafe");
				pploc=0;
				ccarray = origccarray;
				return [];
			}
			allmoves.push(nextmove);
			//Possible problem: pressed button, took another route and end up on new platform...
			while (floor.tiles[pploc]=="ice") {
				ccarray[pploc]="none";
				pploc-=1;
				if (!floor.issafe(pploc)){
					trace("Fell after sliding at "+pploc);
					pploc=0;	
				ccarray = origccarray;
					return [];					
				}
			}
			if (pploc>=Const.racelen) {
				pploc=0;
				ccarray = origccarray;
				return allmoves;
			}
		}
		return []; //Never executed
	}

	public function getnextmoves(){
		var moves = ["jump","skip"];
		var samecol = [];
		var nonempty = [];
		for (mov in moves){
			if (ccarray[pploc] == ccarray[pploc+pp.stepsize.get(mov)])
				samecol.push(mov);
			if (ccarray[pploc+pp.stepsize.get(mov)]=="light" || ccarray[pploc+pp.stepsize.get(mov)]=="dark")
				nonempty.push(mov);
		}

		//Need to recompute this on landing...
		nextmoves = [];
		if (ccarray[pploc]=="none" || samecol.length==0){
			if (nonempty.length==0) {
				//Reluctant move
				//move = moves.randitem();
				nextmoves = moves;
			} else {
				nextmoves = nonempty;
			}
		} else {
			nextmoves = samecol;
		}
		trace("nextmoves "+nextmoves);
	}

	//Super-mode specials tracker
	public function special(s,arg:Dynamic=null):Dynamic{
		if (s=="nofall"){
			if (!Data.supermode) return "";
			if (pony=="Pinkie Pie"){
				//Should add on landing rather than on jumping...
				//ponyspecial.set("nofall",//ponyspecial.get("nofall")+1);
				if (ponyspecial.get("nofall")>3){
					//Should check first time here
					if (ponyspecial.get("firstsuper")) {
						ponyspecial.set("firstsuper",false);
						return "super";
					}
					return "nn";
				} else {
					return "";
				}
			} else {
				return "";
			}
		} else if (s=="yesfall"){
			ponyspecial.set("nofall", 0);
			//Or should this not reset and just keep playing?
			ponyspecial.set("queue", new Array<Int>());
		} else if (s=="queueadd"){
			trace(ponyspecial.get("queue"));
			if (pony=="Twilight"){
				ponyspecial.get("queue").push(arg);
			}
			trace(ponyspecial.get("queue"));
		} else if (s=="queuepop") {
			trace(ponyspecial.get("queue"));
			if (pony=="Twilight"){
				if (ponyspecial.get("queue").length>0)
					return ponyspecial.get("queue").shift();
			}
			return -1;
		} else if (s=="queuetop") {
			if (pony=="Twilight"){
				if (ponyspecial.get("queue").length>0)
					return ponyspecial.get("queue")[0];
			}
			return -1;
		} else if (s=="queuefinish"){
			if (!Data.supermode) return false;
			if (pony!="Twilight") return false;
			if (ponyspecial.get("queuesuper")) return true;
			//Simulate finish
			//keys is a hack for now (because queue stores keycodes)
			var finished = floor.simulate(pploc,ponyspecial.get("queue"),keys);
			trace("sim result:"+finished);
			return (finished>-1);
		} else if (s=="queuesuper"){
			if (!Data.supermode) return "";
			if (!ponyspecial.get("queuesuper")) return "";
			return "arrive-super-";
		} else if (s=="teleporthome"){
			if (arg!=null) ponyspecial.set("teleporthome",arg);
			return ponyspecial.get("teleporthome");
		} else if (s=="undoadd") {
			if (pony=="Rarity"){
				ponyspecial.get("undo").push(arg);
				trace("adding undo:"+ponyspecial.get("undo"));
			}
		} else if (s=="undopop") {
			if (pony=="Rarity"){
				trace("poping undo:"+ponyspecial.get("undo"));
				if (ponyspecial.get("undo").length>0)
					return ponyspecial.get("undo").pop();
			}
			return null;
		} else if (s=="undofallpop") {
			if (pony=="Rarity"){
				trace("poping fall undo:"+ponyspecial.get("undo"));
				if (ponyspecial.get("undo").length>0){
					var val = ponyspecial.get("undo").pop();
					while(val=="slide") val = ponyspecial.get("undo").pop();
				}
			}
			return null;
		} else if (s=="scry on"){
			if (pony=="Twilight"){
				ponyspecial.get("map").visible=true;
				ponyspecial.get("map").x=pp.x+Const.mapxoffset;
			}
		} else if (s=="scry off"){
			if (pony=="Twilight"){
				ponyspecial.get("map").visible=false;
				ponyspecial.get("maptimer").reset();
			}
		} else if (s=="scry start"){
			if (pony=="Twilight"){
				ponyspecial.get("maptimer").start();
			}
		//Fluttershy super
 		} else if (s=="secondfloorfall"){
			if (!Data.supermode || !ponyspecial.get("secondfloorenabled")) return false;
			if (pony=="Fluttershy") {
				trace(!ponyspecial.get("curfloor")+","+ponyspecial.get("firstfloor").isgood(pploc));
				if (!ponyspecial.get("curfloor") && ponyspecial.get("firstfloor").isgood(pploc)){
					floor=ponyspecial.get("firstfloor");
					ponyspecial.set("curfloor",true);
					return true;
				}
			}
 		} else if (s=="enablesecondfloor"){
			if (!Data.supermode) return false;
			if (!ponyspecial.get("secondfloorenabled")){
				if (ponyspecial.get("lastfall")==lastsafe){
					ponyspecial.set("secondfloorenabled",true);
					ponyspecial.get("secondfloor").visible=true;

					return true;
					//ponyspecial.set("secondfloor",.visibletrue);
				}
				ponyspecial.set("lastfall",lastsafe);
			}
			return false;
		} else if (s=="moveup"){
			if (!Data.supermode || !ponyspecial.get("secondfloorenabled")) return false;
			if (pony=="Fluttershy") {
				//trace(ponyspecial.get("curfloor")+","+floor.tiles[pploc]+","+ponyspecial.get("secondfloor"));
				if (ponyspecial.get("curfloor")==true && floor.tiles[pploc]=="rock" && ponyspecial.get("secondfloor").tiles[pploc]=="water"){
					trace("ascending");
					ponyspecial.set("curfloor",false);
					ponyspecial.get("firstfloor").turntowater(pploc);
					floor=ponyspecial.get("secondfloor");
					floor.tiles[pploc]="ascender";
					//pp.y-=Const.floordiffy;
					Tweener.addTween(pp,{y:pp.y-Const.floordiffy,time:0.5});
					return true;
				}
			}
		} else if (s=="takegem"){
			if (["dark","light"].has(ccarray[pploc])){
				cclayer.removeChild(ccsprites[pploc]);
				ccarray[pploc]="none";
				var circle = Uti.gem("empty");//Uti.circle(20,Const.colfs);
				circle.x=Const.tilex+ccpointer*Const.tilex;
				circle.y=260;
				ccsprites[pploc]=circle;
				cclayer.addChild(circle);
			}
		} else if (s=="ra-super"){
			if (ponyspecial.get("rasuper")) return "rasuper-";
			else return "";
		} else if (s=="ra-set-super"){
			ponyspecial.set("raqueue",arg);
			ponyspecial.set("rasuper",true);
		} else if (s=="ra-queuepop"){
			if (pony=="Rarity"){
				if (ponyspecial.get("raqueue").length>0)
					return ponyspecial.get("raqueue").shift();
			}
			return "";
		}
		return null;
	}

	//Achievements tracker
	public function achieve(s,arg:Dynamic=null):Dynamic{
		if (aimode) return;
		if (s=="button_press"){
			ach.set("button_press",ach.get("button_press")+1);
			if (ach.get("button_press")==40){
				getachive("button masher");
			}
		} else if (s=="fall"){
			ach.set("nofall",0);
		}
	}

	public function getachive(s){
		trace("getach:"+s);
		if (s=="button masher"){
			if (Data.achievements.exists("button_masher")) return;
			Data.achievements.set("button_masher","got");
			var newbm = new Bitmap(Res.images.get("pinkie-surprise"));
			newbm.x=pp.x+100;
			newbm.y=pp.y;
			this.addChild(newbm);
			var par=this;
			Tweener.addTween(newbm,{alpha:0,time:5,onComplete:function(){par.removeChild(newbm);}});
		}
	}
}

class HopSkipJump extends Sprite {
	public var tracewindow:TextField;
	public var tracestr:String;
	public var mc:MovieClip;
	public var game:MovieClip;
	//public var gamewindows:Array<MovieClip>;
	public var title:TitleScreen;
	public var gameoverscreen:GameOverScreen;
	public var credits:CreditsScreen;
	public var achscreen:AchievementScreen;
	public var interlevelscreen:InterlevelScreen;

	public var channel:SoundChannel;

	public var loadercount:Int;

	public var animationlayer:Sprite;

	//For garbage collection
	public var starttimer:Timer;
	public var endtimer:Timer;
	public var endgametimer:Timer;

	public function new(){
		super();
		this.tracestr="";
		this.mc=flash.Lib.current;

		tracewindow = new TextField();
		var format:TextFormat = Const.format();
		//tracewindow.autoSize = TextFieldAutoSize.LEFT;
		tracewindow.defaultTextFormat = format;
		tracewindow.multiline = true;
		tracewindow.border = true;
		tracewindow.wordWrap = false;
		tracewindow.background = true;
		mc.addChild(tracewindow);
		tracewindow.width=200;
		tracewindow.height=180;
		tracewindow.y=110;
		tracewindow.x=300;
		tracewindow.text="Trace window\n";

		if (!Const.debug){
			tracewindow.visible = false;
		} else {
			mc.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.kdowndebug);
		}

		Const.init();
		Data.init();
		Res.init(this.loaded2);
		scomplete("bgm",null);

		mc.setChildIndex(tracewindow,mc.numChildren-1);
	}

	static function main() {
		var hsj=new HopSkipJump();
		var s=new Sprite();
		Const.mcs.addChild(s);
		MemoryTracker.track(s,"Sprite0");
		Const.mcs.removeChild(s);
		s=null;
		SWFProfiler.init();
		haxe.Log.trace=hsj.cTrace;
	}

	public function kdowndebug(ev:KeyboardEvent){
		if (ev.keyCode==66){
			trace("Making a lot of sprites");
			var s;
			var m=null;
			var m2;
			var m3;
			var mspr;
			var f;
			for (i in 0...1){
				s = new Sprite();
				m2 = new MovieClip();
				m3 = new MovieClip();
				f = new Floor();
				m3.addChild(f);
				m2.foo=m3;
				m3.foo=m2;
				mspr = new MSprite(null,"Pinkie Pie");
				m = new MovieClip();
				m.gamewindows = new Array<MovieClip>();

				var pony="Pinkie Pie";
				var types = ["water","rock"];
				var num=1;
				var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
				Uti.addgamewindow(m,gamewindow,100);
				//mc.addChild(m);

				mc.addChild(m2);
				mc.addChild(m3);
				mc.addChild(mspr);

				MemoryTracker.track(s,"spr"+i);
				MemoryTracker.track(m,"mov"+i);
				MemoryTracker.track(m2,"mov2-"+i);
				MemoryTracker.track(m3,"mov3-"+i);
				MemoryTracker.track(f,"floor-"+i);

				mc.removeChild(m2);
				mc.removeChild(m3);
				mc.removeChild(mspr);

				//MemoryTracker.track(gamewindow,"mov"+i);
				//mc.removeChild(m);
				var gamewindows:Array<MovieClip> = m.gamewindows;
				for (gamewindow in gamewindows){
					gamewindow.destroy();
					m.removeChild(gamewindow);
				}
			}
			if (m!=null){
				var gamewindows:Array<MovieClip> = m.gamewindows;
				for (gamewindow in gamewindows){
					gamewindow=null;
				}
			}
			m=null;
			s=null;
		} else if (ev.keyCode==67){
			trace(untyped __global__ ["uint"]);
			trace(untyped __keys__(this));
			//trace(Traverse.traverse(Const.mc));
		} else if (ev.keyCode==68){
			try {
				new LocalConnection().connect('foo');
				new LocalConnection().connect('foo');
			} catch (e:Dynamic){
				trace("Forcing Garbage Collection :"+e.toString());
			}
			/*
			trace(Type.getClassFields(Type.getClass(this)));
			trace(Type.getInstanceFields(Type.getClass(this)));
			trace(Type.getClassFields(Type.getClass(par)));
			trace(Type.getInstanceFields(Type.getClass(par)));*/
			//trace(Reflect.fields(Const.mc));
		}
	}

	static function main2(){
		var hsj=new HopSkipJump();
		haxe.Log.trace=hsj.cTrace;
	}

	public function cTrace(v : Dynamic, ?inf : haxe.PosInfos ){
		tracewindow.text+=inf.fileName+":"+inf.lineNumber+" "+v+"\n";
	}

	function loaded2(){
		title = new TitleScreen(this);
		mc.addChild(title);
		mc.setChildIndex(title,0);
		gameoverscreen = new GameOverScreen(this);
		mc.addChild(gameoverscreen);
		mc.setChildIndex(gameoverscreen,1);
		credits = new CreditsScreen(this);
		mc.addChild(credits);
		mc.setChildIndex(credits,1);
		achscreen = new AchievementScreen(this);
		mc.addChild(achscreen);
		mc.setChildIndex(achscreen,1);
		interlevelscreen = new InterlevelScreen(this);
		mc.addChild(interlevelscreen);
		mc.setChildIndex(interlevelscreen,1);
	}

	public function removegame(){
		if (game!=null){
			mc.removeChild(game);
			var gamewindows:Array<DummyWindow> = game.gamewindows;
			for (gamewindow in gamewindows){
				gamewindow.destroy();
				game.removeChild(gamewindow);
			}
			game=null;
		}
	}

	public function selectpony(num=0){
		if (num==0) num=Data.lastlevel;
		trace("Starting selection screen");
		removegame();
		title.disable();
		game = new MovieClip();
		game.gamewindows = new Array<MovieClip>();

		game.levelnum = num;
		if (num>=1){
			//var gamewindow = new SelectWindow(["pp","ts"],[49,50],allselected);
			var gamewindow = new SelectWindow(Data.unlocked,Data.keys[0],allselected);
			game.addChild(gamewindow);
			game.gamewindows.push(gamewindow);
			mc.addChild(game);
			mc.setChildIndex(game,0);
		} else if (num==-1){
			//for (i in 0...3) {
			for (i in 0...3) {
				var gamewindow = new SelectWindow(Data.unlocked,Data.keys[i],allselected);
				game.addChild(gamewindow);
				gamewindow.y = i*100;
				game.gamewindows.push(gamewindow);
			}
			mc.addChild(game);
			mc.setChildIndex(game,0);
		}
	}

	public function allselected(){
		var gamewindows:Array<SelectWindow> = game.gamewindows;
		var ponies = new Array<String>();
		var aimodes = new Array<Bool>();
		var allsel = true;
		for (gamewindow in gamewindows){
			if (gamewindow.pony=="") {
				allsel = false;
				gamewindow.setautoselecttimer();
			} else {
				ponies.push(gamewindow.pony);
				aimodes.push(gamewindow.aimode);
			}
		}
		if (!allsel) return;
		trace("All selected");
		startlevel(game.levelnum,ponies,aimodes);
	}

	public function startlevel(num:Int,ponies=null,aimodes=null){
		trace("level "+num);
		if ((num>=1 && num<=Const.numlevels) || num==-1){
			trace("Starting level");
			removegame();
 			//mc.removeEventListener(KeyboardEvent.KEY_DOWN, title.kdown);
			//mc.removeChild(title);
			title.disable();

			game = new MovieClip();
			game.gamewindows = new Array<GameWindow>();
		}
		if (num==-1) {
			//Multiplayer mode
			Const.racelen=98;
			var types = ["water","rock","ice","button"];
			game.ponies=ponies;
			for  (i in 0...3){
				var pony="Pinkie Pie";
				if (game.ponies!=null) pony=game.ponies[i];
				var keys=null;
				if (aimodes!=null && !aimodes[i]) keys=Data.keys[i];
				var gamewindow = new GameWindow(pony,keys,types,num);
				Uti.addgamewindow(game,gamewindow,i*100);
			}
		} else if (num==1) {
			Const.racelen=30;
			var types = ["water","rock"];
			var rect = Uti.rect(400,100);
			var tf = Const.convtextfield("Press 1 to hop\nPress 2 to skip",Const.colfs);
			tf.addborder(Const.colfsout);
			rect.addChild(tf);
			rect.y=0;
			rect.x=0;
			game.addChild(rect);

			var pony="Pinkie Pie";
			game.ponies=ponies;
			if (game.ponies!=null) pony=game.ponies[0];
			var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
			Uti.addgamewindow(game,gamewindow,100);
			game.humanplayer = 0;

			var rect = Uti.rect(400,100);
			var tf = Const.convtextfield("Get to the end\nas fast as possible",Const.colfs);
			tf.addborder(Const.colfsout);
			rect.addChild(tf);
			rect.y=200;
			rect.x=0;
			game.addChild(rect);

		} else if (num==2){
			Const.racelen=50;
			var types = ["water","rock"];
			var gamewindow = new GameWindow("Pinkie Pie",null,types,num,2);
			Uti.addgamewindow(game,gamewindow);

			var pony="Pinkie Pie";
			game.ponies=ponies;
			if (game.ponies!=null) pony=game.ponies[0];
			var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
			Uti.addgamewindow(game,gamewindow,100);
			game.humanplayer = 1;

			var rect = Uti.rect(400,100);
			var tf = Const.convtextfield("You can now play as\nPinkie Pie",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			rect.y=200;
			rect.x=0;
			game.addChild(rect);
		} else if (num==3){
			Const.racelen=70;
			var types = ["water","rock","ice"];
			var gamewindow = new GameWindow("Pinkie Pie",null,types,num,4);
			Uti.addgamewindow(game,gamewindow);

			var pony="Pinkie Pie";
			game.ponies=ponies;
			if (game.ponies!=null) pony=game.ponies[0];
			var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
			Uti.addgamewindow(game,gamewindow,100);
			game.humanplayer = 1;

			var gamewindow = new GameWindow("Pinkie Pie",null,types,num,4);
			Uti.addgamewindow(game,gamewindow,200);
		} else if (num==4) {
			Const.racelen=90;
			var types = ["water","rock","ice"];
			var gamewindow = new GameWindow("Twilight",null,types,num,6);
			Uti.addgamewindow(game,gamewindow);

			var pony="Pinkie Pie";
			game.ponies=ponies;
			if (game.ponies!=null) pony=game.ponies[0];
			var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
			Uti.addgamewindow(game,gamewindow,100);

			var gamewindow = new GameWindow("Pinkie Pie",null,types,num,6);
			Uti.addgamewindow(game,gamewindow,200);
			game.humanplayer = 1;
		} else if (num==5){
			Const.racelen=98;
			var types = ["water","rock","ice","button"];
			var gamewindow = new GameWindow("Twilight",null,types,num,8);
			Uti.addgamewindow(game,gamewindow);

			var pony="Pinkie Pie";
			game.ponies=ponies;
			if (game.ponies!=null) pony=game.ponies[0];
			var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
			Uti.addgamewindow(game,gamewindow,100);

			var gamewindow = new GameWindow("Pinkie Pie",null,types,num,8);
			Uti.addgamewindow(game,gamewindow,200);
			game.humanplayer = 1;
		} else if (num==6){
			Const.racelen=98;
			var types = ["water","rock","ice","button"];
			var gamewindow = new GameWindow("Twilight",null,types,num,10);
			Uti.addgamewindow(game,gamewindow);

			var pony="Pinkie Pie";
			game.ponies=ponies;
			if (game.ponies!=null) pony=game.ponies[0];
			var gamewindow = new GameWindow(pony,Data.keys[0],types,num);
			Uti.addgamewindow(game,gamewindow,100);

			var gamewindow = new GameWindow("Rarity",null,types,num,10);
			Uti.addgamewindow(game,gamewindow,200);
			game.humanplayer = 1;
		}
		if ((num>=1 && num<=Const.numlevels) || num==-1){
			game.levelnum = num;
			//Possible duplicate
			if (num>=1) Data.lastlevel = num;

			mc.addChild(game);
			mc.setChildIndex(game,0);

			var tf = Const.textfield("3");
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.x=200-tf.width/2;
			tf.y=150-tf.height/2;
			tf.selectable=false;
			tf.addborder(Const.colts);
			
			game.addChild(tf);
			game.starttext = tf;

			//Move to game once it is an object
			if (starttimer!=null){
				starttimer.stop();
				starttimer.removeEventListener("timer",readysetgo);
			}
			starttimer = new Timer(1000,3);
			starttimer.addEventListener("timer",readysetgo,false,0,true);
			starttimer.start();

			if (endtimer!=null){
				endtimer.stop();
				endtimer.removeEventListener("timer",checkgameend);
			}
			endtimer = new Timer(1000);
			endtimer.addEventListener("timer",checkgameend,false,0,true);
			endtimer.start();
		}
	}

	//Cutscene animations
	public function playanimation(num:Int,ponies=null){
		if (num==1){
			//Twilight joins
			scomplete("bgmts",null);

			var animlayer = new Sprite();
			MemoryTracker.track(animlayer,"animlayer");
			animationlayer = animlayer;

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Twilight! Over here!",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("pinkie-surprise"));
			newbm.x=300;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Hi Pinkie.\nHow's cloud walking?",Const.colts);
			tf.x=130;
			tf.addborder(Const.coltsout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("twilight-surprised"));
			newbm.x=0;
			rect.addChild(newbm);

			rect.y=200;
			rect.x=400;
			Tweener.addTween(rect,{x:0, delay:1, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Cloud BOUNCING\nis even better!",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("pinkie-surprise"));
			newbm.x=300;
			rect.addChild(newbm);
			
			rect.y=0;
			rect.x=-400;

			Tweener.addTween(rect,{x:0, delay:2, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("You should try it\nand join our cloudrace!",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("pinkie-happynn"));
			newbm.x=300;
			rect.addChild(newbm);
			
			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, delay:3, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Twilight Sparkle\njoins the race!", Const.colts);
			tf.addborder(Const.coltsout);
			rect.addChild(tf);

			rect.y=100;
			rect.x=400;
			Tweener.addTween(rect,{x:0, time:1, delay:4});

			//Check for null?
			var asprite = Uti.loadasprite("ts-arrive-");
			asprite.visible=true;
			//asprite.eframe(null);
			asprite.visible=false;
			asprite.x=250;asprite.y=60;
			animlayer.addChild(asprite);
			trace("asprite added");
			var t=new Timer(Const.frameratems);
			t.addEventListener("timer",function(e:Event=null){asprite.eframe(null);});
			var par = this;

			mc.addChild(animlayer);

			var par=this;
			asprite.looped = function(){
				asprite.showlast();
				par.nextanim();
			};

			var compl = function(){
				asprite.visible=true;
				Tweener.pauseAllTweens();
				t.start();
			}
			Tweener.addTween(tf,{x:50, time:1, delay:4, onComplete:compl});

			Tweener.addTween(this,{delay:4.1, time:1,
						onComplete:function() {
						  t.stop();
							t.removeEventListener("timer",function(e:Event=null){asprite.eframe(null);});
						  animlayer.visible=false;
							animlayer.removecond(asprite);
  						par.mc.removecond(animlayer);
							animlayer=null;
							par.animationlayer=null;
							par.scomplete("bgm");
							par.interlevelscreen.enable();
							//par.startlevel(4,ponies);
					  }});
			Data.unlock("ts");
		} else if (num==2) {
			//Pinkie Pie joins
			scomplete("bgmpp",null);

			var animlayer = new Sprite();
			MemoryTracker.track(animlayer,"animlayer");
			animationlayer = animlayer;

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Oh hey, Fluttershy!\nWanna cloudrace?",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);

			var newbm = new Bitmap(Res.images.get("pinkie-surprise"));
			newbm.x=300;
			rect.addChild(newbm);
			rect.x=-400;
			Tweener.addTween(rect,{x:0, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Cloud...race?",Const.colfs);
			tf.x+=100;
			tf.addborder(Const.colfsout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("fluttershy-unsure"));
			newbm.x=0;
			rect.addChild(newbm);

			rect.y=200;
			rect.x=400;
			Tweener.addTween(rect,{x:0, delay:1, time:1, onComplete:nextanim});
			//Tweener.addTween(rect,{x:0, delay:3, time:1});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Yeah! It will make\ngetting to Cloudsdale\nso much more fun!",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);

			var newbm = new Bitmap(Res.images.get("pinkie-happynn"));
			newbm.x=300;
			rect.addChild(newbm);
			
			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, delay:2, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);

			var tf = Const.convtextfield("Pinkie Pie\njoins the race!",Const.colpp);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			rect.y=100;
			rect.x=-400;

			var asprite = Uti.loadasprite("pp-win-");
			asprite.visible=false;
			asprite.x=250;asprite.y=60;
			animlayer.addChild(asprite);
			trace("asprite added");
			var t=new Timer(Const.frameratems/2);
			t.addEventListener("timer",function(e:Event=null){asprite.eframe(null);});
			//t.start();
			var par = this;

			mc.addChild(animlayer);

			var par=this;

			var compl = function(){
				asprite.visible=true;
				t.start();
				par.nextanim();
			}

			Tweener.addTween(rect,{x:0, delay:3, time:1, onComplete:compl});
			//Tweener.addTween(rect,{x:0, delay:6, time:1});

			//Not sure what to put for dummy object
			Tweener.addTween(this,{delay:3.1, time:1, onComplete:function(){
						t.stop();
						t.removeEventListener("timer",function(e:Event=null){asprite.eframe(null);});
						animlayer.visible=false;
						animlayer.removeChild(asprite);
						par.mc.removeChild(animlayer);
						animlayer=null;
						par.animationlayer=null;
						par.scomplete("bgm",null);
						par.interlevelscreen.enable();
						//par.startlevel(2,ponies);
					}});
			mc.addChild(animlayer);

			Data.unlock("pp");
		} else if (num==3) {
			//Bouncy clouds introduced
			var animlayer = new Sprite();
			MemoryTracker.track(animlayer,"animlayer");
			animationlayer = animlayer;

			mc.addChild(animlayer);

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Oof. What was that?",Const.colfs);
			tf.addborder(Const.colfsout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("fluttershy-unsure"));
			newbm.x=300;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Ooo! Bouncy!",Const.colpp);
			tf.x+=100;
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("pinkie-surprise"));
			newbm.x=0;
			rect.addChild(newbm);

			rect.y=200;
			rect.x=400;
			Tweener.addTween(rect,{x:0, delay:1, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Bouncy clouds\nahead!",Const.colfs);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			rect.y=100;
			rect.x=-400;

			var asprite = Uti.loadasprite("fs-stand-");
			asprite.x=200;asprite.y=-16;
			rect.addChild(asprite);

			var asprjump = Uti.loadasprite("fs-hop-");
			asprjump.x=asprite.x;asprjump.y=asprite.y;
			rect.addChild(asprjump);
			asprjump.visible=false;

			var t=new Timer(Const.frameratems/2);
			t.addEventListener("timer",function(e:Event=null){asprite.eframe(null);});
			t.start();
			var jumpt=new Timer(Const.frameratems);
			jumpt.addEventListener("timer",function(e:Event=null){asprjump.eframe(null);});
			jumpt.start();

			var newbm = new Bitmap(Res.images.get("cloud"));
			newbm.x=asprite.x+Const.floorxoffset-20;
			newbm.y=asprite.y+90-24;
			rect.addChild(newbm);
			var newbm = new Bitmap(Res.images.get("cloud"));
			newbm.x=asprite.x+Const.floorxoffset+Const.tilex-20;
			newbm.y=asprite.y+90-24;
			rect.addChild(newbm);
			var newbm = new Bitmap(Res.images.get("ice"));
			newbm.x=asprite.x+Const.floorxoffset+Const.tilex*2-20;
			newbm.y=asprite.y+90-24;
			rect.addChild(newbm);
			rect.setChildIndex(asprite,rect.numChildren-1);
			rect.setChildIndex(asprjump,rect.numChildren-1);

			var par = this;

			var compl = function(){
				asprite.visible=false;
				asprjump.visible=true;
				asprite.x=asprjump.x+Const.tilex;
				Tweener.addTween(asprjump,{x:asprjump.x+Const.tilex*2, transition:"linear", delay:1, time:0.5});
				Tweener.addTween(asprjump,{x:asprjump.x+Const.tilex, transition:"linear", delay:1.5, time:0.5,onComplete:function(){
							asprjump.visible=false;
							asprite.visible=true;
							par.nextanim();
						}});
				//par.nextanim();
			}
			var d=2;
			Tweener.addTween(rect,{x:0, time:1,delay:d});
			d+=1;
			Tweener.addTween(this,{delay:d, time:1, onComplete:compl});

			Tweener.addTween(this,{delay:d+2.1, time:1, onComplete:function(){
						t.stop();
						t.removeEventListener("timer",function(e:Event=null){asprite.eframe(null);});
						jumpt.stop();
						jumpt.removeEventListener("timer",function(e:Event=null){asprjump.eframe(null);});
						animlayer.visible=false;
						rect.removecond(asprite);
						rect.removecond(asprjump);
						par.mc.removecond(animlayer);
						animlayer=null;
						par.animationlayer=null;
						par.interlevelscreen.enable();
						//par.startlevel(3,ponies);
					}});
		} else if (num==4) {
			//Button clouds introduced
			var animlayer = new Sprite();
			MemoryTracker.track(animlayer,"animlayer");
			animationlayer = animlayer;

			mc.addChild(animlayer);

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("What is this? What\ndoes this button do?",Const.colts);
			tf.addborder(Const.coltsout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("twilight-surprised"));
			newbm.x=300;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Oh. This is where\nthe clouds are made.",Const.colfs);
			tf.x+=100;
			tf.addborder(Const.colfsout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("fluttershy-unsure"));
			newbm.x=0;
			rect.addChild(newbm);

			rect.y=200;
			rect.x=400;
			Tweener.addTween(rect,{x:0, delay:1, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("I've read about cloud\nmakers. So this is what\nthey actually look like.",Const.colts);
			tf.addborder(Const.coltsout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("twilight-surprised"));
			newbm.x=300;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, delay:2, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Cloud makers\nahead!",Const.colfs);
			tf.addborder(Const.colppout);
			rect.addChild(tf);
			rect.y=100;
			rect.x=-400;

			var asprite = Uti.loadasprite("fs-stand-");
			asprite.x=200-30;asprite.y=-16;
			rect.addChild(asprite);

			var asprjump = Uti.loadasprite("fs-hop-");
			asprjump.x=asprite.x;asprjump.y=asprite.y;
			rect.addChild(asprjump);
			asprjump.visible=false;

			var t=new Timer(Const.frameratems/2);
			t.addEventListener("timer",function(e:Event=null){asprite.eframe(null);});
			t.start();
			var jumpt=new Timer(Const.frameratems);
			jumpt.addEventListener("timer",function(e:Event=null){asprjump.eframe(null);});
			jumpt.start();

			var newbm = new Bitmap(Res.images.get("cloud"));
			newbm.x=asprite.x+Const.floorxoffset-20;
			newbm.y=asprite.y+90-24;
			rect.addChild(newbm);
			var newbm = new Bitmap(Res.images.get("button"));
			newbm.x=asprite.x+Const.floorxoffset+Const.tilex-20;
			newbm.y=asprite.y+90-24;
			rect.addChild(newbm);
			var bpressed = new Bitmap(Res.images.get("button-pressed"));
			bpressed.x=asprite.x+Const.floorxoffset+Const.tilex-20;
			bpressed.y=asprite.y+90-24;
			rect.addChild(bpressed);
			bpressed.visible=false;
			var platform = new Bitmap(Res.images.get("cloud"));
			platform.x=asprite.x+Const.floorxoffset+Const.tilex-20;
			platform.y=asprite.y+90-24;
			platform.visible=false;
			rect.addChild(platform);
			rect.setChildIndex(asprite,rect.numChildren-1);
			rect.setChildIndex(asprjump,rect.numChildren-1);

			var par = this;

			var compl = function(){
				asprite.visible=false;
				asprjump.visible=true;
				asprite.x=asprjump.x+Const.tilex;
				Tweener.addTween(asprjump,{x:asprjump.x+Const.tilex, transition:"linear", delay:1, time:0.5, onComplete:function(){
							asprjump.visible=false;
							asprite.visible=true;
							bpressed.visible=true;
							platform.visible=true;
						}});
				Tweener.addTween(platform,{x:platform.x+Const.tilex*2, delay:1.5, time:1, onComplete:function(){par.nextanim();}});
				//par.nextanim();
			}
			var d=3;
			Tweener.addTween(rect,{x:0, time:1,delay:d});
			d+=1;
			Tweener.addTween(this,{delay:d, time:1, onComplete:compl});
			d+=2;
			Tweener.addTween(this,{delay:d+0.6, time:1, onComplete:function(){
						t.stop();
						t.removeEventListener("timer",function(e:Event=null){asprite.eframe(null);});
						jumpt.stop();
						jumpt.removeEventListener("timer",function(e:Event=null){asprjump.eframe(null);});
						animlayer.visible=false;
						rect.removeChild(asprite);
						rect.removeChild(asprjump);
						par.mc.removeChild(animlayer);
						animlayer=null;
						par.animationlayer=null;
						par.interlevelscreen.enable();
						//par.startlevel(5,ponies);
					}});
		} else if (num==5) {
			//Rarity joins
			scomplete("bgmra",null);

			var animlayer = new Sprite();
			MemoryTracker.track(animlayer,"animlayer");
			animationlayer = animlayer;

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Is this the place?",Const.colra);
			tf.addborder(Const.colraout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("rarity-confused"));
			newbm.x=400-newbm.width;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Yeah! Maybe I can get my cutie\nmark in the cloudrace!\nHurry up, sis!",Const.colsb);
			tf.x+=100;

			tf.addborder(Const.colsbout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("sb-cheer"));
			newbm.x=0;
			rect.addChild(newbm);

			rect.y=200;
			rect.x=400;
			Tweener.addTween(rect,{x:0, delay:1, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("But these clouds,\nthey look so...",Const.colra);
			tf.addborder(Const.colraout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("rarity-disgust"));
			newbm.x=400-newbm.width;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, delay:2, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Maybe if I add this and\nthat one there and...",Const.colra);
			tf.addborder(Const.colraout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("rarity-inspired"));
			newbm.x=400-newbm.width;
			rect.addChild(newbm);

			rect.y=0;
			rect.x=-400;
			Tweener.addTween(rect,{x:0, delay:3, time:1, onComplete:nextanim});

			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("",Const.colsb);
			tf.x+=100;

			tf.addborder(Const.colsbout);
			rect.addChild(tf);
			var newbm = new Bitmap(Res.images.get("sb-unsure"));
			newbm.x=0;
			rect.addChild(newbm);

			rect.y=200;
			rect.x=400;
			Tweener.addTween(rect,{x:0, delay:5.5, time:1, onComplete:nextanim});


			var rect = Uti.rect(400,100);
			animlayer.addChild(rect);
			var tf = Const.convtextfield("Rarity joins the\ncloud decorating\ncontest!",Const.colra);
			tf.addborder(Const.colraout);
			rect.addChild(tf);

			rect.y=100;
			rect.x=400;

			var asprite = Uti.loadasprite("ra-magic-left-");
			asprite.visible=false;
			asprite.x=250;asprite.y=100;
			animlayer.addChild(asprite);
			trace("asprite added");
			var t=new Timer(Const.frameratems/2);
			t.addEventListener("timer",function(e:Event=null){asprite.eframe(null);});
			//t.start();
			var par = this;

			mc.addChild(animlayer);

			var par=this;

			var compl = function(){
				asprite.visible=true;
				t.start();
				//par.nextanim();
			}

			Tweener.addTween(rect,{x:0, delay:4, time:1, onComplete:compl});
			//Tweener.addTween(rect,{x:0, delay:6, time:1});

			//Not sure what to put for dummy object
			Tweener.addTween(this,{delay:6.6, time:1, onComplete:function(){
						t.stop();
						t.removeEventListener("timer",function(e:Event=null){asprite.eframe(null);});
						animlayer.visible=false;
						par.mc.removeChild(animlayer);
						animlayer.removeChild(asprite);
						animlayer=null;
						par.animationlayer=null;
						par.scomplete("bgm",null);
						par.interlevelscreen.enable();
						//par.startlevel(6,ponies);
					}});
			mc.addChild(animlayer);

			Data.unlock("ra");
		}
		Data.save();
	}

	function nextanim(){
		trace("pausing");
		Tweener.pauseAllTweens();
		flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.unpause);
		trace("listener added");
	}

	function unpause (ev:Event){
		trace("unpausing");
		Tweener.resumeAllTweens();
		flash.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.unpause);
	}

	function readysetgo(ev:Event){
		trace("ready");
		var num=ev.target.repeatCount-ev.target.currentCount;
		trace(num);
		game.starttext.text = ""+num;
		if (Const.debugfaststart) {num=0; ev.target.stop();}
		if (num==0){
			game.starttext.visible = false;
			var gamewindows:Array<GameWindow> = game.gamewindows;
			for (gamewindow in gamewindows){
				gamewindow.togglepause();
				gamewindow.racestart();
			}
		}
	}

	function checkgameend(ev:Event){
		var gamewindows:Array<GameWindow> = game.gamewindows;
		if (game.gamewindows[0].levelnum!=-1 && game.gamewindows[game.humanplayer].ended()){
			for (gamewindow in gamewindows) gamewindow.changeaidiff(10);			
		}
		for (gamewindow in gamewindows){
			if (!gamewindow.ended()) return;
		}
		for (gamewindow in gamewindows){
			if (!gamewindow.paused) gamewindow.togglepause();
		}
		ev.target.stop();
		var playertimes = new Array<Float>();
		for (gamewindow in gamewindows){
			playertimes.push(Std.parseFloat(gamewindow.timertf.text.split(":")[1]));
		}
		trace(playertimes);
		var winner = playertimes.index(playertimes.min());
		trace(winner);

		if (endtimer!=null){
			endtimer.stop();
			endtimer.removeEventListener("timer",checkgameend);
			endtimer=null;
		}

		if (endgametimer!=null){
			endgametimer.stop();
			endgametimer.removeEventListener("timer",callback(gameend,winner));
		}
		endgametimer = new Timer(1000);
		endgametimer.addEventListener("timer",callback(gameend,winner));
		endgametimer.start();

		game.starttext.text = "Player "+winner+" wins";
		game.starttext.visible = true;
		//mc.addChild(tf);
	}

	function gameend(winner:Int,ev:Event){
		ev.target.stop();
		ev.target.removeEventListener("timer",callback(gameend,winner));

		var newbesttime=false;
		var racetime = -1;

		if (game.levelnum > 0){
			racetime = game.gamewindows[game.humanplayer].finishtime;
			var levelkey = "Level"+game.levelnum;
			trace("racetime "+racetime+" "+levelkey);
			if (racetime>0 && (!Data.besttime.exists(levelkey) || racetime<Data.besttime.get(levelkey))){
				trace("racetime "+racetime+" "+levelkey);
				newbesttime=true;
				Data.besttime.set(levelkey,racetime);
				if (!Data.achievements.exists("rainbow_dasher") && racetime<=10*Const.millis){
					Data.achievements.set("rainbow_dasher","got");
				}
			}

			//Junior speedster
			if (!Data.achievements.exists("junior_speedster")){
				var levelcount = 0;
				var speedach = true;
				for (time in Data.besttime.iterator()){
					trace(time);
					if (time>=60*Const.millis) {speedach = false; break;}
					levelcount+=1;
				}
				trace(levelcount+" "+Const.numlevels+" "+speedach);
				if (speedach && levelcount>=Const.numlevels) {
					Data.achievements.set("junior_speedster","got");
					//Animate
				}
			}
		}

		//Check archiements

		if (game.levelnum > 0 && winner != game.humanplayer){
			gameoverscreen.enable();
		} else if (game.levelnum == 1){
			interlevelscreen.settype("nextlevel",2,racetime,newbesttime);
			playanimation(2);
		} else if (game.levelnum == 2){
			interlevelscreen.settype("nextlevel",3,racetime,newbesttime);
			playanimation(3);
		} else if (game.levelnum == 3){
			interlevelscreen.settype("nextlevel",4,racetime,newbesttime);
			playanimation(1);
		} else if (game.levelnum == 4){
			interlevelscreen.settype("nextlevel",5,racetime,newbesttime);
			playanimation(4);
		} else if (game.levelnum == 5){
			interlevelscreen.settype("nextlevel",6,racetime,newbesttime);
			playanimation(5);
		} else if (game.levelnum == -1) {
			title.enable();
		} else if (game.levelnum == Const.numlevels) {
			//title.enable();
			Data.supermodeunlocked=true;
			Data.lastlevel=1;
			interlevelscreen.settype("lastlevel",-2,racetime,newbesttime);
			interlevelscreen.enable();
		} else {
			playanimation(2);
		}
	}

	function gototitle(){
		title.enable();
	}

	public function removeall(){
		if (game!=null && this.contains(game)) {
			mc.removeChild(game);
			var gamewindows:Array<GameWindow> = game.gamewindows;
			for (gamewindow in gamewindows){
				gamewindow.destroy();
				game.removeChild(gamewindow);
			}
		}
		if (animationlayer!=null) {
			mc.removeChild(animationlayer);
			animationlayer=null;
		}
		Tweener.removeAllTweens();
	}

	function scomplete(sound:String,ev:Event=null){
		if (sound=="bgm"){
			if (channel!=null){
				channel.stop();
				channel.removeEventListener(Event.SOUND_COMPLETE, callback(scomplete,"bgm"));
			}

			channel = Res.sounds.get("bgm").play();
			var soundtransf = channel.soundTransform;
			soundtransf.volume = 0.4;
			channel.soundTransform = soundtransf;
			channel.addEventListener(Event.SOUND_COMPLETE, callback(scomplete,"bgm"));
		} else if (sound=="bgmpp"){
			if (channel!=null){
				channel.stop();
				channel.removeEventListener(Event.SOUND_COMPLETE, callback(scomplete,"bgm"));
			}
			channel = Res.sounds.get("bgmpp").play();
			var soundtransf = channel.soundTransform;
			soundtransf.volume = 0.3;
			channel.soundTransform = soundtransf;
			channel.addEventListener(Event.SOUND_COMPLETE, callback(scomplete,"bgmpp"));
		} else if (sound=="bgmts"){
			if (channel!=null){
				channel.stop();
				channel.removeEventListener(Event.SOUND_COMPLETE, callback(scomplete,sound));
			}

			channel = Res.sounds.get(sound).play();
			var soundtransf = channel.soundTransform;
			soundtransf.volume = 0.4;
			channel.soundTransform = soundtransf;
			channel.addEventListener(Event.SOUND_COMPLETE, callback(scomplete,sound));
		} else if (sound=="bgmra"){
			if (channel!=null){
				channel.stop();
				channel.removeEventListener(Event.SOUND_COMPLETE, callback(scomplete,sound));
			}

			channel = Res.sounds.get(sound).play();
			var soundtransf = channel.soundTransform;
			soundtransf.volume = 0.4;
			channel.soundTransform = soundtransf;
			channel.addEventListener(Event.SOUND_COMPLETE, callback(scomplete,sound));
		}
	}
}
