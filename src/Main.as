package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import Karabiner.Component.DraggableObject;
	import Karabiner.Component.ImageObject;
	import Karabiner.Component.PageIndicator;
	import Karabiner.Component.ScrollPageList;
	import Karabiner.Component.SimpleDraggableObject;
	import Karabiner.Component.SliderObject;
	import Karabiner.Component.VirticalScrollContainer;
	import Karabiner.Constant.DRAG_DIRECTION;
	import Karabiner.Constant.IMAGE_FIT_TYPE;
	import Karabiner.Event.SliderEvent;
	import SampleButton;
	
	/**
	 * Karabiner UI Samples
	 */
	public class Main extends MovieClip 
	{
		private var view:MovieClip;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// view from swc
			view = new MainView();
			this.addChild(view);
			
			// setup sample components
			SetupSampleButton();
			SetupSampleLoadImage();
			SetupSampleSimpleDraggable();
			SetupSampleSmoothDraggable();
			SetupSampleScrollText();
			SetupSampleScrollAndSlider();
			SetupSampleScrollPage();
		}
		
		private function SetupSampleButton():void
		{
			var btn:SampleButton = new SampleButton();
			btn.WrapFromSWC(view.getChildByName("sample_button"));
		}
		
		private function SetupSampleLoadImage():void
		{
			var image:ImageObject = new ImageObject("https://dl.dropboxusercontent.com/u/4733593/Karabiner/load_image.png", null, false);
			image.SetPostLoadSizing(100, 100);
			image.addEventListener(Event.COMPLETE, function(e:Event):void {
				(view.getChildByName("sample_load_image") as MovieClip).addChild(image);
			});
			
			// wait 3s for load start
			var timer:Timer = new Timer(3000, 1);
			timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				image.LoadImage();
			});
			timer.start();
		}
		
		private function SetupSampleSimpleDraggable():void
		{
			var drag:SimpleDraggableObject = new SimpleDraggableObject();
			drag.WrapFromSWC(view.getChildByName("sample_simple_draggable"));
			drag.SetDragMoveArea(view.getChildByName("sample_drag_area").getRect(view));
		}
		
		private function SetupSampleSmoothDraggable():void
		{
			var drag:DraggableObject = new DraggableObject(new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight));
			drag.WrapFromSWC(view.getChildByName("sample_smooth_draggable"));
			drag.DragStart();
		}
		
		private function SetupSampleScrollText():void
		{
			var container:VirticalScrollContainer = new VirticalScrollContainer(view.getChildByName("sample_scroll_mask_1").getRect(view));
			container.WrapFromSWC(view.getChildByName("sample_scroll_text_1"));
			container.InitDrag();
		}
		
		private function SetupSampleScrollAndSlider():void
		{
			var masked_area:Rectangle = view.getChildByName("sample_scroll_mask_2").getRect(view);
			var scroll_text:MovieClip = view.getChildByName("sample_scroll_text_2") as MovieClip;
			
			var slider:SliderObject = new SliderObject(DRAG_DIRECTION.VIRTICAL);
			slider.WrapFromSWC(view.getChildByName("sample_slider"));
			
			var container:VirticalScrollContainer = new VirticalScrollContainer(masked_area, slider);
			container.WrapFromSWC(scroll_text);
			container.InitDrag();
			
			// slider value event
			slider.addEventListener(SliderEvent.CHANGE_SLIDER_VALUE, function(e:Event):void {
				container.SetScroll(slider.SliderValue, slider.height);
			});
			slider.SetThumbSize(masked_area.height / scroll_text.height);
			slider.InitDrag();
		}
		
		private function SetupSampleScrollPage():void
		{
			// create pages
			var pages:Array/*MovieClip*/ = new Array();
			pages.push(new Page1());
			pages.push(new Page2());
			pages.push(new Page3());
			
			var pageList:ScrollPageList = new ScrollPageList(pages, pages[0].width);
			view.addChildAt(pageList, 1);
			
			// page ingicator
			var pageIngicator:PageIndicator = new PageIndicator(pageList, pages.length, 50, IngicatorBtnView);
			pageIngicator.x = 400;
			pageIngicator.y = 540;
			view.addChildAt(pageIngicator, 2);
		}
	}
}