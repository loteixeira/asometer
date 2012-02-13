package br.dcoder
{
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * @author lteixeira
	 */
	public class MemoryMonitorTest extends Sprite
	{
		private static const CREATION_INTERVAL:uint = 25;
		
		private var testContainer:Sprite;
		private var center:Point;
		private var particles:Array;
		private var lastUpdate:uint;
		
		public function MemoryMonitorTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(event:Event):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resize);
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			MemoryMonitor.create(stage);
			
			setTimeout(start, 1000);
		}
		
		private function resize(event:Event):void
		{
			if (center)
			{
				center.x = stage.stageWidth / 2;
				center.y = stage.stageHeight / 2;
			}
		}
		
		private function start():void
		{
			testContainer = new Sprite();
			addChild(testContainer);
			
			center = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			particles = new Array();
			lastUpdate = getTimer();
			
			testContainer.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function stop():void
		{
			testContainer.removeEventListener(Event.ENTER_FRAME, enterFrame);
			removeChild(testContainer);
			
			center = null;
			particles = null;
		}
		
		private function enterFrame(event:Event):void
		{
			var now:uint = getTimer();
			var toRemove:Array = new Array();
			var i:int;
			var obj:Object;
			
			if (now - lastUpdate >= CREATION_INTERVAL)
			{
				createParticle();
				lastUpdate = now;
			}
			
			for (i = 0; i < particles.length; i++)
			{
				obj = particles[i];
				var shape:Shape = obj["shape"];
				
				if (shape.x < 0 || shape.x >= stage.stageWidth || shape.y < 0 || shape.y >= stage.stageHeight)
				{
					toRemove.push(i);
					continue;
				}
				
				obj["radius"] += obj["radiusVel"];
				obj["theta"] += obj["thetaVel"];
				
				shape.x = center.x + obj["radius"] * Math.cos(obj["theta"]);
				shape.y = center.y + obj["radius"] * Math.sin(obj["theta"]);
			}
			
			for (i = toRemove.length - 1; i >= 0; i--)
			{
				obj = particles[toRemove[i]];
				testContainer.removeChild(obj["shape"]);
				particles.splice(toRemove[i], 1);
			}
		}
		
		private function createParticle():void
		{
			var color:uint = Math.random() * 0xffffff;
			
			var shape:Shape = new Shape();
			shape.x = center.x;
			shape.y = center.y;
			testContainer.addChild(shape);
			
			shape.graphics.lineStyle(undefined);
			shape.graphics.beginGradientFill(GradientType.RADIAL, [color, color], [1, 0], [0, 40]);
			shape.graphics.drawCircle(0, 0, 10 + Math.random() * 10);
			shape.graphics.endFill();
			
			shape.blendMode = BlendMode.ADD; 
			
			var obj:Object =
			{
				radius: 0,
				theta: 0,
				radiusVel: 0.5 + Math.random() * 2,
				thetaVel: Math.random() * (Math.PI / 64),
				shape: shape
			};
			
			particles.push(obj);
		}
	}
}
