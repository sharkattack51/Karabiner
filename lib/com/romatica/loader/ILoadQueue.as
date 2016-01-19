/**
 *============================================================
 * copyright(c). 
 * @author  itoz
 *============================================================
 *
 */
package com.romatica.loader
{
	/**
	 * ILoadQueue
	 */
	public interface ILoadQueue
	{
		function add( url: String 
					, compFunc		: Function 
					, progressFunc  : Function = null 
					, openFunc 		: Function = null 
					, errorFunc 	: Function = null) : void
					
		function load():void;
		
		//function remove (url : String) : void;
		
		function stop (url : String) : void;
		
		function allStop () : void;
		
		function allClear () : void;
	}
}
