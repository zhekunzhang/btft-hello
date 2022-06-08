package com.intel.btft.hello;
import android.test.InstrumentationTestCase;
import android.util.Log;
public class hello extends testFTest{
    static{
    System.loadLibrary("hello");
    }

    public void testbtftmain(){
    Log.i("hello", "btftmain");
    assertTrue(btftmain());
    }
    public native boolean btftmain();

}