package  
{
	import flash.text.TextField;
	import Karabiner.Component.ButtonBase;
	import Karabiner.Enum.ON_BUTTON_TYPE;
	
	/**
	 * SampleButton
	 */
	public class SampleButton extends ButtonBase
	{
		private var count:int = 0;
		
		
		public function SampleButton():void
		{
			super(ON_BUTTON_TYPE.CLICK);
		}
		
		
		// button function
		override protected function OnButton():void
		{
			super.OnButton();
			
			trace("Play SE & Execute Button Function !!");
			
			(this.parent.getChildByName("count_text") as TextField).text = String(count++);
		}
	}
}