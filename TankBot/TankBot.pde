/* BluetoothApp2: Written by ScottC on 1st April 2013 using 
 Processing version 2.0b8
 Tested on a Samsung Galaxy SII, with Android version 2.3.4
 Android ADK - API 10 SDK platform
 Apwidgets version: r44 : http://code.google.com/p/apwidgets/
 */


/*------------------------------------------------------------------------------
 IMPORT statements required for this sketch
 -----------------------------------------------------------------------------*/
import android.content.BroadcastReceiver; 
import android.content.Context; 
import android.content.Intent; 
import android.content.IntentFilter; 

import android.bluetooth.BluetoothAdapter; 
import android.bluetooth.BluetoothDevice; 
import android.bluetooth.BluetoothSocket; 

import java.io.IOException; 
import java.io.OutputStream; 
import java.util.UUID; 
import android.util.Log; 

import apwidgets.APWidgetContainer;
import apwidgets.APButton; 
import apwidgets.APWidget;
import apwidgets.OnClickWidgetListener;


/*------------------------------------------------------------------------------
 GLOBAL Variables to be used between a number of classes.
 -----------------------------------------------------------------------------*/
public int[] bg= {
  0, 80, 0
};
public BluetoothDevice btShield = null;
public BluetoothSocket btSocket = null;
public OutputStream btOutputStream = null;
public APWidgetContainer widgetContainer=null;
public Connect2BtDevice ConBTdevice=new Connect2BtDevice();



/*------------------------------------------------------------------------------
 The following variables are used to setup the Buttons used in the GUI
 of the phone. It includes the variables that determine the
 - text on the buttons
 - the number of buttons
 - the letters that will be sent to Arduino when the buttons are pressed
 - the colour that the background will change to when the buttons are pressed
 - the dimensions of the buttons (width and height)
 - The gap between each button
 -----------------------------------------------------------------------------*/
String[] buttonText = { 
  "Forward", "Back", "Left", "Right", "Stop"
}; //Button Labels
String[] sendLetter= {
  "w", "s", "a", "d", "q"
}; //Letters to send when button pressed
int n= buttonText.length; //Number of buttons
int[][] buttonColour = { 
  {
    255, 10, 10
  }
  , 
  {
    10, 255, 10
  }
  , 
  {
    10, 10, 255
  }
  , 
  {
    0, 0, 0
  }
}; //The Background colour on phone when button pressed


APButton[] guiBtns = new APButton[n]; //Array of buttons
int gap=10; //gap between buttons
int buttonWidth=0; //initialising the variable to hold the WIDTH of each button
int buttonHeight=0; //initialising the variable to hold the HEIGHT of each button




/*------------------------------------------------------------------------------
 The setup() method is used to connect to the Bluetooth Device, and setup
 the GUI on the phone.
 -----------------------------------------------------------------------------*/
void setup() {
  new Thread(ConBTdevice).start(); //Connect to SeeedBTSlave device
  orientation(LANDSCAPE); //Make GUI appear in landscape mode

  //Setup the WidgetContainer and work out the size of each button
  widgetContainer = new APWidgetContainer(this);
  buttonWidth=((width/n)-(n*(gap/2))); //button width depends on screen width
  buttonHeight=(height/2); //button height depends on screen height

  //Add ALL buttons to the widgetContainer.
  for (int i=0; i<n;i++) {
    guiBtns[i]= new APButton(((buttonWidth*i)+(gap*(i+1))), gap, buttonWidth, buttonHeight, buttonText[i]);
    widgetContainer.addWidget(guiBtns[i]);
  }
}



/*------------------------------------------------------------------------------
 The draw() method is only used to change the colour of the phone's background
 -----------------------------------------------------------------------------*/
void draw() {
  background(bg[0], bg[1], bg[2]);
}




/*------------------------------------------------------------------------------
 onClickWidget is called when a button is clicked/touched, which will
 change the colour of the background, and send a specific letter to the Arduino.
 The Arduino will use this letter to change the colour of the RGB LED 
 -----------------------------------------------------------------------------*/
void onClickWidget(APWidget widget) { 
  String letrToSend="";

  /*Identify the button that was pressed, Change the phone background 
   colout accordingly and choose the letter to send */
  for (int i=0; i<n;i++) {
    if (widget==guiBtns[i]) {
      ConBTdevice.changeBackground(buttonColour[i][0], 
      buttonColour[i][1], 
      buttonColour[i][2]);
      letrToSend=sendLetter[i];
    }
  }

  /* Send the chosen letter to the Arduino/Bluetooth Shield */
  if (ConBTdevice!=null) {
    ConBTdevice.write(letrToSend);
  }
}



/*==============================================================================
 CLASS: Connect2BtDevice implements Runnable
 - used to connect to remote bluetooth device and send values to the Arduino
 ==================================================================================*/
public class Connect2BtDevice implements Runnable {

  /*------------------------------------------------------------------------------
   Connect2BtDevice CLASS Variables 
   -----------------------------------------------------------------------------*/
  BluetoothAdapter btAdapter=null;
  BroadcastReceiver broadcastBtDevices=null;
  private UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");



  /*------------------------------------------------------------------------------
   DEFAULT CONSTRUCTOR: Connect2BtDevice() 
   - Create a BroadcastReceiver (registered in run() method).
   - Get the default Bluetooth Adapter
   - Enable the adapter (if it is not already enabled).
   - Discover available Bluetooth devices to connect to 
   -----------------------------------------------------------------------------*/
  public Connect2BtDevice() {
    broadcastBtDevices = new btBroadcastReceiver();
    getBtAdapter();
    enableBtAdapter();
    discoverBtDevices();
  }



  /*------------------------------------------------------------------------------
   run() method
   - used to register the broadcast receiver only
   -----------------------------------------------------------------------------*/
  @Override
    public void run() {
    registerReceiver(broadcastBtDevices, new IntentFilter(BluetoothDevice.ACTION_FOUND));
  }



  /*------------------------------------------------------------------------------
   getBtAdapter() method
   - get the default Bluetooth adapter
   -----------------------------------------------------------------------------*/
  void getBtAdapter() {
    btAdapter = BluetoothAdapter.getDefaultAdapter();
  }



  /*------------------------------------------------------------------------------
   enableBtAdapter() method
   - Enable the default Bluetooth Adapter if it isn't already enabled
   -----------------------------------------------------------------------------*/
  void enableBtAdapter() {
    if (!btAdapter.isEnabled()) {
      btAdapter.enable();
    }
  }



  /*------------------------------------------------------------------------------
   discoverBtDevices() method
   - Discover other Bluetooth devices within range (ie SeeedBTSlave device)
   -----------------------------------------------------------------------------*/
  void discoverBtDevices() {
    while (!btAdapter.isEnabled ()) {
      //Wait until the Bluetooth Adapter is enabled before continuing
    }
    if (!btAdapter.isDiscovering()) {
      btAdapter.startDiscovery();
    }
  }



  /*------------------------------------------------------------------------------
   connect2Bt() method: called by the btBroadcastReceiver
   - Create a BluetoothSocket with the discovered Bluetooth device
   - Change background to yellow at this step
   - Connect to the discovered Bluetooth device through the BluetoothSocket
   - Wait until socket connects then
   - Attach an outputStream to the BluetoothSocket to communicate with Bluetooth
   device. (ie. Bluetooth Shield on the the Arduino)
   - Write a "g" string through the outputStream to change the colour of the LED
   to green and change the phone background colour to green also.
   A green screen and green LED suggests a successful connection, plus the
   Bluetooth shield's onboard LED starts flashing green slowly (1 per second),
   which also confirms the successful connection.
   -----------------------------------------------------------------------------*/
  void connect2Bt() {
    try {
      btSocket = btShield.createRfcommSocketToServiceRecord(uuid);
      changeBackground(255, 255, 0); //YELLOW Background
      try {
        btSocket.connect();
        while (btSocket==null) {
          //Do nothing
        }
        try {
          btOutputStream = btSocket.getOutputStream();
          changeBackground(0, 255, 0); //Green Background
          write("g"); //Green LED (Successful connection)
        }
        catch (IOException e) { 
          Log.e("ConnectToBluetooth", "Error when getting output Stream");
        }
      }
      catch(IOException e) {
        Log.e("ConnectToBluetooth", "Error with Socket Connection");
        changeBackground(255, 0, 0); //Red background
      }
    }
    catch(IOException e) {
      Log.e("ConnectToBluetooth", "Error with Socket Creation");
      changeBackground(255, 0, 0); //Red background
      try {
        btSocket.close(); //try to close the socket
      }
      catch(IOException closeException) {
        Log.e("ConnectToBluetooth", "Error Closing socket");
      }
      return;
    }
  }


  /*------------------------------------------------------------------------------
   write(String str) method
   - Allows you to write a String to the remote Bluetooth Device
   -----------------------------------------------------------------------------*/
  public void write(String str) {
    try {
      btOutputStream.write(stringToBytes(str));
    } 
    catch (IOException e) { 
      Log.e("Writing to Stream", "Error when writing to btOutputStream");
    }
  }



  /*------------------------------------------------------------------------------
   byte[] stringToBytes(String str) method
   - Used by the write() method 
   - This method is used to convert a String to a byte[] array
   - This code snippet is from Byron: 
   http://www.javacodegeeks.com/2010/11/java-best-practices-char-to-byte-and.html
   -----------------------------------------------------------------------------*/
  public byte[] stringToBytes(String str) {
    char[] buffer = str.toCharArray();
    byte[] b = new byte[buffer.length << 1];
    for (int i = 0; i < buffer.length; i++) {
      int bpos = i << 1;
      b[bpos] = (byte) ((buffer[i]&0xFF00)>>8);
      b[bpos + 1] = (byte) (buffer[i]&0x00FF);
    }
    return b;
  }



  /*------------------------------------------------------------------------------
   cancel() method
   - Can be called to close the Bluetooth Socket
   -----------------------------------------------------------------------------*/
  public void cancel() {
    try {
      btSocket.close();
    } 
    catch (IOException e) {
    }
  }



  /*------------------------------------------------------------------------------
   changeBackground(int bg0, int bg1, int bg2) method
   - A method to change the background colour of the phone screen
   -----------------------------------------------------------------------------*/
  void changeBackground(int bg0, int bg1, int bg2) {
    bg[0] = bg0;
    bg[1] = bg1;
    bg[2] = bg2;
  }
}


/*==============================================================================
 CLASS: btBroadcastReceiver extends BroadcastReceiver
 - Broadcasts a notification when the "SeeedBTSlave" is discovered/found.
 - Use this notification as a trigger to connect to the remote Bluetooth device
 ==================================================================================*/
public class btBroadcastReceiver extends BroadcastReceiver {
  @Override
    public void onReceive(Context context, Intent intent) {
    String action=intent.getAction();
    /* Notification that BluetoothDevice is FOUND */
    if (BluetoothDevice.ACTION_FOUND.equals(action)) {
      /* Get the discovered device Name */
      String discoveredDeviceName = intent.getStringExtra(BluetoothDevice.EXTRA_NAME);

      /* If the discovered Bluetooth device Name =SeeedBTSlave then CONNECT */
      if (discoveredDeviceName.equals("SeeedBTSlave")) { 
        /* Get a handle on the discovered device */
        btShield = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        /* Connect to the discovered device. */
        ConBTdevice.connect2Bt();
      }
    }
  }
}

