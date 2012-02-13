package br.dcoder
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
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
		private static const INTERVAL:uint = 1000;
		private static const MAX_DATA:uint = 30;
		private static const TEXT_HEIGHT:uint = 15;
		private static const TEXT_SIZE:uint = 10;
		
		private static var stage:Stage;
		private static var container:Sprite;
		private static var minLayer:Shape;
		private static var maxLayer:Shape;
		private static var curLayer:Shape;
		
		private static var fpsTextField:TextField;
		private static var minTextField:TextField;
		private static var maxTextField:TextField;
		private static var currentTextField:TextField;

		private static var align:String;
		private static var offsetX:uint, offsetY:uint;
		private static var data:Array;
		
		private static var minMemory:uint, maxMemory:uint, currentMemory:uint;
		private static var frameCount:uint, lastFpsCheck:uint;
		
		public static function create(stage:Stage, align:String = TOP_LEFT, alpha:Number = 0.85):void
		{
			MemoryMonitor.stage = stage;
			MemoryMonitor.align = align;
			
			offsetX = Math.round(WIDTH / 20);
			offsetY = Math.round(HEIGHT / 20);
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(Event.RESIZE, resize);
			
			container = new Sprite();
			container.alpha = alpha;
			stage.addChild(container);
			
			// chart layers
			minLayer = new Shape();
			minLayer.y = offsetY;
			container.addChild(minLayer);
			
			maxLayer = new Shape();
			maxLayer.y = offsetY;
			container.addChild(maxLayer);
			
			curLayer = new Shape();
			curLayer.alpha = 0.75;
			curLayer.y = offsetY;
			container.addChild(curLayer);
			
			// text fields
			var textFormat:TextFormat;
			
			fpsTextField = new TextField();
			fpsTextField.selectable = false;
			fpsTextField.y = Math.round(HEIGHT - offsetY - TEXT_HEIGHT);
			container.addChild(fpsTextField);
			
			textFormat = new TextFormat();
			textFormat.font = "_typewriter";
			textFormat.size = TEXT_SIZE;
			textFormat.color = 0x000000;
			fpsTextField.defaultTextFormat = textFormat;
			
			minTextField = new TextField();
			minTextField.selectable = false;
			minTextField.y = Math.round(HEIGHT - offsetY - TEXT_HEIGHT);
			container.addChild(minTextField);
			
			textFormat = new TextFormat();
			textFormat.font = "_typewriter";
			textFormat.size = TEXT_SIZE;
			textFormat.color = 0x0000ff;
			minTextField.defaultTextFormat = textFormat;
			
			maxTextField = new TextField();
			maxTextField.selectable = false;
			maxTextField.y = Math.round(HEIGHT - offsetY - TEXT_HEIGHT);
			container.addChild(maxTextField);
			
			textFormat = new TextFormat();
			textFormat.font = "_typewriter";
			textFormat.size = TEXT_SIZE;
			textFormat.color = 0xff0000;
			maxTextField.defaultTextFormat = textFormat;
			
			currentTextField = new TextField();
			currentTextField.selectable = false;
			currentTextField.y = Math.round(HEIGHT - offsetY - TEXT_HEIGHT);
			container.addChild(currentTextField);
			
			textFormat = new TextFormat();
			textFormat.font = "_typewriter";
			textFormat.size = TEXT_SIZE;
			textFormat.color = 0x00aa00;
			currentTextField.defaultTextFormat = textFormat;
			
			updateText(0, 0, 0, 0);
			
			// memory data
			data = new Array();
			
			for (var i:uint = 0; i < MAX_DATA; i++)
				data.push([NaN, NaN, NaN]);
			
			minMemory = uint.MAX_VALUE;
			maxMemory = uint.MIN_VALUE;
			currentMemory = 0;
			
			frameCount = 0;
			lastFpsCheck = getTimer();
			
			// draw, resize and initialize
			drawContainer();
			resize(null);
			
			setInterval(update, INTERVAL);
		}
		
		public function getAlign():String
		{
			return align;
		}
		
		private static function enterFrame(event:Event):void
		{
			frameCount++;
		}
		
		private static function resize(event:Event):void
		{
			if (align == TOP_LEFT)
			{
				container.x = 0;
				container.y = 0;
			}
			else if (align == TOP_RIGHT)
			{
				container.x = stage.stageWidth - WIDTH;
				container.y = 0;
			}
			else if (align == BOTTOM_LEFT)
			{
				container.x = 0;
				container.y = stage.stageHeight - HEIGHT;
			}
			else if (align == BOTTOM_RIGHT)
			{
				container.x = stage.stageWidth - WIDTH;
				container.y = stage.stageHeight - HEIGHT;
			}
		}
		
		private static function drawContainer():void
		{
			container.graphics.clear();
			container.graphics.beginFill(0xffffff);
			container.graphics.lineStyle(1, 0x000000);
			container.graphics.drawRect(0, 0, WIDTH - 1, HEIGHT - 1);
			container.graphics.endFill();
			
			container.graphics.lineStyle(1, 0xcccccc);
			
			var h:Number = (HEIGHT - 2 - TEXT_HEIGHT - offsetY * 2) / 5;
			var w:Number = WIDTH - 2;
			
			for (var i:uint = 0; i <= 5; i++)
			{
				container.graphics.moveTo(1, offsetY + i * h);
				container.graphics.lineTo(w, offsetY + i * h);
			}
		}
		
		private static function updateText(fps:uint, minMem:Number, maxMem:Number, curMem:Number):void
		{
			fpsTextField.text = fps + "fps";
			minTextField.text = minMem + "mb";
			maxTextField.text = maxMem + "mb";
			currentTextField.text = curMem + "mb";
			
			fpsTextField.x = Math.round(offsetX / 2);
			minTextField.x = Math.round(fpsTextField.x + fpsTextField.textWidth + offsetX / 2);
			maxTextField.x = Math.round(minTextField.x + minTextField.textWidth + offsetX / 2);
			currentTextField.x = Math.round(maxTextField.x + maxTextField.textWidth + offsetX / 2);
		}
		
		private static function drawData():void
		{
			var w:uint = WIDTH - 2;
			var h:uint = HEIGHT - 2 - offsetY * 2 - TEXT_HEIGHT;
			
			minLayer.graphics.clear();
			minLayer.graphics.lineStyle(1, 0x0000ff);
			
			maxLayer.graphics.clear();
			maxLayer.graphics.lineStyle(1, 0xff0000);
			
			curLayer.graphics.clear();
			curLayer.graphics.lineStyle(1, 0x00cc00);
			
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
			
			var now:uint = getTimer();
			var fps:uint = Math.round(frameCount / ((now - lastFpsCheck) / 1000));
			lastFpsCheck = now;
			frameCount = 0;

			updateText(fps, minMem, maxMem, curMem);
			
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
