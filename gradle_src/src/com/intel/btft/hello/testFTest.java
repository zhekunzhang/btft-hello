package com.intel.btft.hello;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;

import android.content.Context;
import android.content.res.Resources;
import android.test.InstrumentationTestCase;
import android.util.Log;
import com.jayway.android.robotium.solo.BTCodeCoverage;


public class testFTest extends InstrumentationTestCase {
	static Context mCtx;
	static Resources mRes;

	protected void setUp() throws Exception {
		super.setUp();
		mCtx = getInstrumentation().getContext();
		mRes = mCtx.getResources();
		//Log.i("testFTest", "CopyArmLib");
		CreatDir("userLibs");
		CreatDir("reference");
		CopyFiles();
	}
	protected void tearDown(){
		new BTCodeCoverage().ccovExit();
		try {
			this.finalize();
		} catch (Throwable e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void writeRef(String refName, String context) throws IOException{
		String str1 = mCtx.getPackageName();
		String dirPath = "/data/data/" + str1 + "/" + "reference/"+refName + ".out";//
		File result = new File(dirPath);
		BufferedWriter bw = new BufferedWriter(new FileWriter(result, true));
		//Log.i("writeRef",context);
		bw.write(context);
		bw.flush();
		bw.close();
	}
	
	public String getReference(String refName) throws IOException{
		String str1 = mCtx.getPackageName();
		String dirPath = "/data/data/" + str1 + "/" + "reference/"+refName + ".out";//
		File result = new File(dirPath);
		BufferedReader br = new BufferedReader(new FileReader(result));
		String getString = null;
		String ref = null;
		while ((getString = br.readLine())!=null){
			//Log.i("getReference",getString);
			ref = ref + getString;
		}
		//Log.i("getReference",ref);
		br.close();
		return ref;
	}
	private static void CreatDir(String dirName) {
		String str1 = mCtx.getPackageName();
		String dirPath = "/data/data/" + str1 + "/" + dirName;//
		//Log.i("testFTest", "dirPath is " + dirPath);
		try {
			File dir = new File(dirPath);//
			if (!dir.exists()) {//
				//System.out.println("not exists");
				if (dir.mkdirs()) {//
					//System.out.println("mkdir succ");
				} else {
					//System.out.println("mkdir failed");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static void CopyFiles() throws InterruptedException {
		String str1 = mCtx.getApplicationInfo().sourceDir;
		try {
			//Log.i("testFTest", "str1 is " + str1);
			JarFile localJarFile1 = new JarFile(str1);
			Enumeration<JarEntry> localEnumeration = localJarFile1.entries();
			for (;;) {
				if (!localEnumeration.hasMoreElements()) {
					//System.out.println("no jar");
					return;
				}
				JarEntry localJarEntry = (JarEntry) localEnumeration
						.nextElement();
				String str2 = localJarEntry.getName();
				if(str2.startsWith("assets")){
					String dirName = "";
					//Log.i("testFTest", "str2 is " + str2);
					if(str2.endsWith(".so")){
						dirName = "userLibs"; 
						//Log.i("testFTest", "copy libs");
					}
					else{
						dirName = "reference";
						//Log.i("testFTest", "copy files");
					}
					//String str3 = str2.replaceAll("assets/", "");
					int pos = str2.lastIndexOf("/");
					String str3 = str2.substring(pos+1);
					String str4 = mCtx.getPackageName();
					String str5 = "/data/data/" + str4 + "/" + dirName + "/"
							+ str3;
					//Log.i("testFTest", "paramString is " + str5);
					realCopy(str5, localJarFile1, localJarEntry);
/*					Runtime localRuntime1 = Runtime.getRuntime();
					String str6 = "chmod 777 " + str5;
					localRuntime1.exec(str6).waitFor();*/
				}
			}
		} catch (IOException localIOException2) {
			localIOException2.fillInStackTrace();
		}
	}

	public static void realCopy(String paramString, JarFile paramJarFile,
			ZipEntry paramZipEntry) {
		try {
			File localFile = new File(paramString);
			if(localFile.exists())
			{
				//System.out.println(paramString + " exits");
				return;
			}
			byte[] arrayOfByte = new byte[65536];
			InputStream localInputStream = paramJarFile
					.getInputStream(paramZipEntry);
			BufferedInputStream localBufferedInputStream = new BufferedInputStream(
					localInputStream);
			FileOutputStream localFileOutputStream = new FileOutputStream(
					localFile);
			BufferedOutputStream localBufferedOutputStream = new BufferedOutputStream(
					localFileOutputStream);
			for (;;) {
				int i = localBufferedInputStream.read(arrayOfByte);
				if (i <= 0) {
					localBufferedOutputStream.flush();
					localBufferedOutputStream.close();
					localBufferedInputStream.close();
					return;
				}
				localBufferedOutputStream.write(arrayOfByte, 0, i);
			}
			// return;
		} catch (Exception localException) {
			localException.fillInStackTrace();
		}
	}

}
