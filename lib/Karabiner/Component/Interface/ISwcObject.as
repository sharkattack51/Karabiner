package Karabiner.Component.Interface 
{
	import flash.display.DisplayObject;
	
	/**
	 * ISwcObject
	 * SWCに配置されたオブジェクトをラップするインターフェース
	 */
	public interface ISwcObject 
	{
		function WrapFromSWC(targetObj:DisplayObject):void;
	}
}