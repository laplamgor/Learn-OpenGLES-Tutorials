package com.learnopengles.android.rbgrnlivewallpaper;

import android.opengl.GLSurfaceView.Renderer;

import com.learnopengles.android.lesson3.LessonThreeRenderer;
import com.learnopengles.android.lesson6.LessonSixRenderer;

public class LessonThreeWallpaperService extends OpenGLES2WallpaperService {
	@Override
	Renderer getNewRenderer() {
		return new LessonSixRenderer(this);
	}
}
