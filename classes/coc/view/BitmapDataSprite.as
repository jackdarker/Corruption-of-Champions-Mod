/**
 * Coded by aimozg on 04.06.2017.
 */
package coc.view {
import coc.view.UIUtils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;

[Style(name="fillColor", type="uint", format="Color", inherit="no")]
public class BitmapDataSprite extends Sprite {
	public function BitmapDataSprite(options:Object = null) {
		super();
		if (options) {
			if ('stretch' in options) stretch = options.stretch;
			if ('repeat' in options) repeat = options.stretch;
			for (var key:String in options) {
			if (options.hasOwnProperty(key)) {
				var value:* = options[key];
					if (key == "fillColor") value = UIUtils.convertColor(value);
						if (key in this) {
							this[key] = value;
						} else {
							trace("Unknown BitmapDataSprite property", key)
						}
				}
			}
		}
	}
	private var _bitmap:Bitmap   = null;
	private var _fillColor:uint  = 0;
	private var _width:Number    = 0;
	private var _height:Number   = 0;
	private var _stretch:Boolean = false;
	private var _repeat:Boolean  = false;
	public function set bitmapClass(value:Class):void {
		if (value as Class) bitmap = (new value()) as Bitmap;
		else bitmap = null;
	}
	public function get bitmapClass():Class {
		return null;
	}
	public function get bitmap():Bitmap {
		return _bitmap;
	}
	public function set bitmap(value:Bitmap):void {
		_bitmap = value;
		if (value) {
			if (_width == 0 || !stretch && !repeat) _width = value.width;
			if (_height == 0 || !stretch && !repeat) _height = value.height;
		}
		redraw();
	}
	public function get fillColor():uint {
		return _fillColor;
	}
	public function set fillColor(value:uint):void {
		_fillColor = value;
		redraw();
	}
	override public function set width(value:Number):void {
		_width      = value;
		redraw();
		super.width = value;
	}
	override public function set height(value:Number):void {
		_height      = value;
		redraw();
		super.height = value;
	}
	public function get stretch():Boolean {
		return _stretch;
	}
	public function set stretch(value:Boolean):void {
		_stretch = value;
		redraw();
	}
	public function get repeat():Boolean {
		return _repeat;
	}
	public function set repeat(value:Boolean):void {
		_repeat = value;
		redraw();
	}
	private function redraw():void {
		this.graphics.clear();
		if (bitmap) {
			if (stretch) {
				var m:Matrix = new Matrix();
				m.scale(_width / bitmap.width, _height / bitmap.height);
				this.graphics.beginBitmapFill(bitmap.bitmapData, m, false, true);
			} else {
				this.graphics.beginBitmapFill(bitmap.bitmapData, null, repeat);
			}
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
		} else {
			this.graphics.beginFill(_fillColor, 1.0);
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
		}
	}
}
}
