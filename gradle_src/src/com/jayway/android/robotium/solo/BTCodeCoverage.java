package com.jayway.android.robotium.solo;
import android.util.Log;
import java.io.*;

public class BTCodeCoverage
{
    public boolean isX86Arch() {
        try {
            Process process = Runtime.getRuntime().exec("getprop ro.product.cpu.abilist");
            InputStreamReader ir = new InputStreamReader(process.getInputStream());
            BufferedReader input = new BufferedReader(ir);
            final String abilist = input.readLine();
            if (!abilist.isEmpty()) {
               final String[] abi = abilist.split(",");
               if(abi[0].contains("x86_64")) {
                    Log.i("cvccov", "abi is x86_64:  " + abi[0]);
                    return true;
                } else if (abi[0].contains("x86")) {
                    Log.i("cvccov", "abi is x86:  " + abi[0]);
                    return true;
                } else {
                   Log.i("cvccov", "abi is not x86 or x86_64:  " + abi[0]);
                   return false;
                }
           } else {
               Log.i("cvccov", "abilist is empty");
               return false;
           }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int ccovExit()
    {
        File libcv = new File("/data/system/libcvccov.so");
        Log.i("cvccov", "===================");
        if(isX86Arch())
        {
	    	if(libcv.exists() && !libcv.isDirectory())
	        {
	            //Log.i("cvccov", "start load libcvccov.so!!");
	        	System.load("/data/system/libcvccov.so");
	                
		        Log.i("cvccov", "start call gcov_exit!");
	        	return invokeCodeCoverageExit();
        	}
        	else
        	{
        		Log.i("cvccov", "skip code coverage collection !");
        	}
	    }
	    
	    return 1;
    }

    public native int invokeCodeCoverageExit();
}
