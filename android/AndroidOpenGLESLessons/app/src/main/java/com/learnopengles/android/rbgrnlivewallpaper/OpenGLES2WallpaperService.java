package com.learnopengles.android.rbgrnlivewallpaper;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.content.res.Resources;
import android.opengl.GLSurfaceView.Renderer;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;

import com.learnopengles.android.lesson6.LessonSixRenderer;

public abstract class OpenGLES2WallpaperService extends GLWallpaperService {
	@Override
	public Engine onCreateEngine() {
		return new OpenGLES2Engine();
	}
	
	class OpenGLES2Engine extends GLWallpaperService.GLEngine {

		private Renderer currentRenderer = null;


		@Override
		public void onCreate(SurfaceHolder surfaceHolder) {
			super.onCreate(surfaceHolder);
			
			// Check if the system supports OpenGL ES 2.0.
			final ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
			final ConfigurationInfo configurationInfo = activityManager.getDeviceConfigurationInfo();
			final boolean supportsEs2 = configurationInfo.reqGlEsVersion >= 0x20000;
			
			if (supportsEs2) 
			{
				// Request an OpenGL ES 2.0 compatible context.
				setEGLContextClientVersion(2);

				// Set the renderer to our user-defined renderer.
				currentRenderer = getNewRenderer();
				setRenderer(currentRenderer);

				DisplayMetrics displayMetrics = Resources.getSystem().getDisplayMetrics();
				mDensity = displayMetrics.density;
			} 
			else 
			{
				// This is where you could create an OpenGL ES 1.x compatible
				// renderer if you wanted to support both ES 1 and ES 2.
				return;
			}			
		}



		// Offsets for touch events
		private float mPreviousX;
		private float mPreviousY;
		private float mDensity;

		@Override
		public void onTouchEvent(MotionEvent event) {


			if (event != null)
			{
				float x = event.getX();
				float y = event.getY();

				if (event.getAction() == MotionEvent.ACTION_MOVE)
				{
					if ((LessonSixRenderer)currentRenderer != null)
					{
						float deltaX = (x - mPreviousX) / mDensity / 2f;
						float deltaY = (y - mPreviousY) / mDensity / 2f;

						((LessonSixRenderer)currentRenderer).mDeltaX += deltaX;
						((LessonSixRenderer)currentRenderer).mDeltaY += deltaY;
					}
				}

				mPreviousX = x;
				mPreviousY = y;
			}
			else
			{
				super.onTouchEvent(event);
			}
//
//					Log.e("test", "onTouchEvent: " + x);
		}
	}	

	abstract Renderer getNewRenderer();
}

