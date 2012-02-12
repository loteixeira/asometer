package br.dcoder
{
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author lteixeira
	 */
	public class MemoryMonitorTest extends Sprite
	{
		public function MemoryMonitorTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			MemoryMonitor.create(stage);
		}
	}
}
