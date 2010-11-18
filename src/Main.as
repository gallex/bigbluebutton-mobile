package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.bigbluebutton.mobile.services.ConfigParameters;
	import org.bigbluebutton.mobile.services.UserService;
	
	public class Main extends Sprite
	{
		private var configParameters:ConfigParameters;
		private var userService:UserService;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageWidth = 1024;
			stage.stageHeight = 768;
			configParameters = new ConfigParameters(configLoaded);
		}
		
		private function configLoaded():void{
			trace(configParameters.application);
			
			userService = new UserService();
			userService.startService(configParameters.application, configParameters.host);
		}
		
		private function displayText(text:String):void{
			var tf:TextField = new TextField();
			var format:TextFormat = new TextFormat();
			format.font = "_sans";
			format.size = 12;
			tf.defaultTextFormat = format;
			tf.text = text;
			tf.width = 800;
			tf.x = 10;
			tf.y = 10;
			addChild(tf);
		}
	}
}