package br.dcoder
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.setInterval;

	/**
	 * @author lteixeira
	 */
	public class MemoryMonitor {
		public static const TOP_LEFT:String = "topLeft";
		public static const TOP_RIGHT:String = "topRight";
		public static const BOTTOM_LEFT:String = "bottomLeft";
		public static const BOTTOM_RIGHT:String = "bottomRight";
		
		private static const WIDTH:uint = 180;
		private static const HEIGHT:uint = 60;
		private static const INTERVAL:uint = 2000;
		private static const MAX_DATA:uint = 30;
		
		private static var stage:Stage;
		private static var container:Sprite;
		private static var minLayer:Shape;
		private static var maxLayer:Shape;
		private static var curLayer:Shape;
		private static var textField:TextField;

		private static var _align:String;
		private static var _alpha:Number;
		private static var offsetX:uint, offsetY:uint;
		private static var data:Array;
		
		private static var minMemory:uint, maxMemory:uint, currentMemory:uint;
		private static var lastFpsUpdate:uint, fpsCount:uint, lastFps:uint;
		
		public static function create(stage:Stage, _align:String = TOP_LEFT, _alpha:Number = 0.85):void
		{
			MemoryMonitor.stage = stage;
			MemoryMonitor._align = _align;
			MemoryMonitor._alpha = _alpha;
			
			offsetX = Math.round(WIDTH / 20);
			offsetY = Math.round(HEIGHT / 20);
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(Event.RESIZE, resize);
			
			container = new Sprite();
			container.alpha = _alpha;
			stage.addChild(container);
			
			minLayer = new Shape();
			minLayer.x = offsetX;
			minLayer.y = offsetY;
			container.addChild(minLayer);
			
			maxLayer = new Shape();
			maxLayer.x = offsetX;
			maxLayer.y = offsetY;
			container.addChild(maxLayer);
			
			curLayer = new Shape();
			curLayer.alpha = 0.75;
			curLayer.x = offsetX;
			curLayer.y = offsetY;
			container.addChild(curLayer);
			
			textField = new TextField();
			textField.selectable = false;
			textField.width = WIDTH - offsetX * 2;
			container.addChild(textField);
			updateText(0, 0, 0);
			
			textField.x = offsetX;
			textField.y = Math.round(HEIGHT - offsetY - textField.textHeight);
			
			data = new Array();
			
			for (var i:uint = 0; i < MAX_DATA; i++)
				data.push([NaN, NaN, NaN]);
			
			minMemory = uint.MAX_VALUE;
			maxMemory = uint.MIN_VALUE;
			currentMemory = 0;
			
			fpsCount = lastFps = 0;
			lastFpsUpdate = getTimer();
			
			drawContainer();
			resize(null);
			
			setInterval(update, INTERVAL);
		}
		
		public function get align():String
		{
			return _align;
		}

		public function get alpha():Number
		{
			return _alpha;
		}
		
		private static function enterFrame(event:Event):void
		{
			var now:uint = getTimer();
			
			if (now - lastFpsUpdate >= 1000) {
				lastFps = fpsCount;
				fpsCount = 0;
				lastFpsUpdate = now;
			} else {
				fpsCount++;
			}
		}
		
		private static function resize(event:Event):void
		{
			if (_align == TOP_LEFT)
			{
				container.x = 0;
				container.y = 0;
			}
			else if (_align == TOP_RIGHT)
			{
				container.x = stage.stageWidth - WIDTH - 1;
				container.y = 0;
			}
			else if (_align == BOTTOM_LEFT)
			{
				container.x = 0;
				container.y = stage.stageHeight - HEIGHT - 1;
			}
			else if (_align == BOTTOM_RIGHT)
			{
				container.x = stage.stageWidth - WIDTH - 1;
				container.y = stage.stageHeight - HEIGHT - 1;
			}
		}
		
		private static function drawContainer():void
		{
			container.graphics.clear();
			container.graphics.beginFill(0xffffff);
			container.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			container.graphics.endFill();
			
			container.graphics.lineStyle(1, 0xcccccc);
			
			var h:Number = (HEIGHT - textField.textHeight - offsetY * 2) / 5;
			var w:Number = WIDTH - offsetX * 2;
			
			for (var i:uint = 0; i <= 5; i++)
			{
				container.graphics.moveTo(offsetX, offsetY + i * h);
				container.graphics.lineTo(offsetX + w, offsetY + i * h);
			}
			
			container.graphics.lineStyle(1, 0x000000);
			container.graphics.drawRect(0, 0, WIDTH, HEIGHT);
		}
		
		private static function updateText(minMem:Number, maxMem:Number, curMem:Number):void
		{
			textField.htmlText = "<font face='_typewriter' color='#0000ff' size='10'>" + minMem + "mb</font> <font face='_typewriter' color='#ff0000' size='10'>" + maxMem + "mb</font> <font face='_typewriter' color='#00bb00' size='10'>" + curMem + "mb</font> <font face='_typewriter' color='#000000' size='10'>" + lastFps + "fps</font>";
		}
		
		private static function drawData():void
		{
			var w:uint = WIDTH - offsetX * 2;
			var h:uint = HEIGHT - offsetY * 2 - textField.textHeight;
			
			minLayer.graphics.clear();
			minLayer.graphics.lineStyle(1, 0x0000ff);
			
			maxLayer.graphics.clear();
			maxLayer.graphics.lineStyle(1, 0xff0000);
			
			curLayer.graphics.clear();
			curLayer.graphics.lineStyle(1, 0x00ff00);
			
			var diff:uint = maxMemory - minMemory;
			var first:Boolean = true;
			
			for (var i:uint = 0; i < data.length; i++)
			{
				if (isNaN(data[i][0]) || isNaN(data[i][1]) || isNaN(data[i][2]))
					continue;
				
				var x:Number, y:Number;
				
				var min:uint = data[i][0];
				var max:uint = data[i][1];
				var cur:uint = data[i][2];

				// min memory
				x = (i / (MAX_DATA - 1)) * w;
				y = (1 - (min - minMemory) / diff) * h;
				
				if (first)
					minLayer.graphics.moveTo(x, y);
				else
					minLayer.graphics.lineTo(x, y);
					
				// max memory
				x = (i / (MAX_DATA - 1)) * w;
				y = (1 - (max - minMemory) / diff) * h;
				
				if (first)
					maxLayer.graphics.moveTo(x, y);
				else
					maxLayer.graphics.lineTo(x, y);
					
				// current memory
				x = (i / (MAX_DATA - 1)) * w;
				y = (1 - (cur - minMemory) / diff) * h;
				
				if (first)
					curLayer.graphics.moveTo(x, y);
				else
					curLayer.graphics.lineTo(x, y);
					
				first = false;
			}
		}
		
		private static function update():void
		{
			currentMemory = System.totalMemory;
			
			if (currentMemory < minMemory)
				minMemory = currentMemory;
				
			if (currentMemory > maxMemory)
				maxMemory = currentMemory;
			
			for (var i:uint = 0; i < MAX_DATA - 1; i++)
			{
				data[i][0] = data[i + 1][0];
				data[i][1] = data[i + 1][1];
				data[i][2] = data[i + 1][2];
			}
				
			data[MAX_DATA - 1][0] = minMemory;
			data[MAX_DATA - 1][1] = maxMemory;
			data[MAX_DATA - 1][2] = currentMemory;
						
			var minMem:Number = Math.round((minMemory / 1048576) * 10) / 10;
			var maxMem:Number = Math.round((maxMemory / 1048576) * 10) / 10;
			var curMem:Number = Math.round((currentMemory / 1048576) * 10) / 10;
			updateText(minMem, maxMem, curMem);
			
			drawData();
			toFront();
		}
		
		private static function toFront():void
		{
			while (stage.getChildIndex(container) < stage.numChildren - 1)
				stage.swapChildren(container, stage.getChildAt(stage.getChildIndex(container) + 1));
		}
	}
}
