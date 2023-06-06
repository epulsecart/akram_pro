package com.cybitsec.souqcardstoreapp;

import io.flutter.embedding.android.FlutterActivity;

import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Bundle;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Debug;
import android.os.Environment;
import android.os.StrictMode;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.util.Config;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import javax.xml.transform.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.bluetooth.BluetoothDevice;
import android.os.Bundle;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;


import com.example.hoinprinterlib.HoinPrinter;
import com.example.hoinprinterlib.module.PrinterCallback;
import com.example.hoinprinterlib.module.PrinterEvent;
import com.example.hoinprinterlib.module.PrinterModule;
import com.example.hoinprinterlib.utils.DebugLog;
import com.example.hoinprinterlib.utils.LibUtil;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;

import am.util.printer.PrinterWriter;
import am.util.printer.PrinterWriter58mm;
import am.util.printer.PrinterWriter80mm;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;

import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;
import com.journeyapps.barcodescanner.BarcodeEncoder;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.cybitsec.souqcardstoreapp/text";
    String taha = "hello taha";
    Set<BluetoothDevice> devices;

    private static HoinPrinter instance = null;
    private PrinterModule mPrinterModule;
    private boolean mType58 = true;
    private PrinterCallback mCallback;
    private Context mContext;
    private int mMode;



    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {


        LinearLayout layout = new LinearLayout(MainActivity.this);

        class forprinter {
            public void forPrintArabicText(String text, int size) {
                layout.setGravity(Gravity.CENTER_HORIZONTAL);
                layout.setOrientation(LinearLayout.VERTICAL);
                TextView textView = new TextView(MainActivity.this);
                textView.setWidth(396);
                textView.setPadding(2,0,2,0);
                textView.setGravity(Gravity.CENTER_HORIZONTAL);
                textView.setLayoutParams(new LinearLayout.LayoutParams
                        (LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT, 0));
                textView.setTextColor(Color.BLACK);
                textView.setTypeface(null, Typeface.BOLD);
                textView.setVisibility(View.VISIBLE);
                textView.setTextSize(size);

                textView.setText(text);

                layout.addView(textView);
            }

            public void forPrintImage (String imageUrl) {
                try {
                    URL url = new URL(imageUrl);
                    InputStream in = new BufferedInputStream(url.openStream());
                    ByteArrayOutputStream out = new ByteArrayOutputStream();
                    byte[] buf = new byte[1024];
                    int n = 0;
                    while (-1!=(n=in.read(buf)))
                    {
                        out.write(buf, 0, n);
                    }
                    out.close();
                    in.close();
                    byte[] response = out.toByteArray();
                    // FileOutputStream fos = new FileOutputStream(Environment.getExternalStorageDirectory() + File.separator + "/DCIM/Camera/taha.jpg");
                    // fos.write(response);
                    // fos.close();

                    Bitmap bmp = BitmapFactory.decodeByteArray(response, 0, response.length);
                    ImageView imageView = new ImageView(MainActivity.this);
                    imageView.setImageBitmap(bmp);

                    layout.addView(imageView);
                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("hello taha");
                }
            }

            public void forPrintQrCodeImage(String text) {
                ImageView imageView = new ImageView(MainActivity.this);

                MultiFormatWriter writer = new MultiFormatWriter();

                try {
                    BitMatrix matrix = writer.encode(text, BarcodeFormat.QR_CODE, 200, 200);

                    BarcodeEncoder encoder = new BarcodeEncoder();

                    Bitmap bitmap = encoder.createBitmap(matrix);

                    imageView.setImageBitmap(bitmap);

                    layout.addView(imageView);
                } catch (WriterException e) {
                    e.printStackTrace();
                }
            }
        }


        System.out.println("طه أهلا طه");
        System.out.println("taha is taha");
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},1);

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        super.configureFlutterEngine(flutterEngine);
        HoinPrinter mHoinPrinter = HoinPrinter.getInstance(this.getBaseContext(), 1, new com.example.hoinprinterlib.module.PrinterCallback() {

            @Override
            public void onState(int i) {
                System.out.println("Your string here 1 " + i);
            }

            @Override
            public void onError(int i) {
                System.out.println("Your string here 2 " + i);
            }

            @Override
            public void onEvent(PrinterEvent printerEvent) {
                System.out.println("Your string here 3 " + printerEvent.toString());
            }
        });


        class data{
            String name;
            String address;
            public data(String name, String address){
                this.name = name;
                this.address = address;
            }
            public void showData(){
                System.out.println("Value of a ="+name);
                System.out.println("Value of b ="+address);
            }
        };



        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            // TODO
                            if (call.method.equals("getText")) {
                                result.success(taha);

                                taha = "yes";
                            } else if (call.method.equals("getBlueToothDevices")) {
                                System.out.println("Your taha ");

                                mHoinPrinter.startBtDiscovery();

                                devices =  mHoinPrinter.getPairedDevice();
                                System.out.println(devices);

                                if (devices.size() == 0) {
                                    result.success("empty");
                                } else {
                                    final List list = new ArrayList();

                                    for (BluetoothDevice device : devices) {
                                        //data taha = new data(device.getName(), device.getAddress());
                                        list.add(device.getName() + "--" + device.getAddress());
                                        // stringDevices = device.getName();



                                        //  break;
                                    }
                                    System.out.println("obj");
                                    System.out.println(list);
                                    result.success(list);
                                }


                                taha = "yes";
                            } else if (call.method.equals("connectToPrinter")) {
                                System.out.println("connecting");
                                String printerAddress = call.argument("printerAddress");
                                System.out.println("connect " + printerAddress);
                                mHoinPrinter.destroy();
                                mHoinPrinter.connect(printerAddress);

                                result.success("connect");

                            } else if (call.method.equals("print")) {
                                layout.removeAllViews();

                                System.out.println("print");
                                String companyImage = call.argument("companyImage");
                                String productName = call.argument("productName");
                                int textSize = call.argument("textSize");
                                String productNumber = call.argument("productNumber");
                                String productSerial = call.argument("productSerial");
                                String product_broughtDate = call.argument("product_broughtDate");
                                String product_expiryDate = call.argument("product_expiryDate");
                                String product_shippingMethod = call.argument("product_shippingMethod");

                                forprinter printing = new forprinter();


                                Bitmap bitmapLayerOne_main = Bitmap.createBitmap(400, 500, Bitmap.Config.RGB_565);
                                Canvas canvasLayerOne_main = new Canvas(bitmapLayerOne_main);

                                printing.forPrintImage(companyImage);
                                printing.forPrintArabicText(productName, textSize);
                                printing.forPrintArabicText("******************", textSize);
                                printing.forPrintArabicText("رقم التفعيل - Activation Number one", textSize);
                                printing.forPrintArabicText(productNumber, textSize);

                                printing.forPrintQrCodeImage(productNumber);

                                printing.forPrintArabicText("Purchase Date: " + product_broughtDate, textSize);
                                printing.forPrintArabicText("Expiry Date: " + product_expiryDate, textSize);

                                printing.forPrintArabicText("Serial No: ", textSize);
                                printing.forPrintArabicText(productSerial, textSize);

                                printing.forPrintArabicText("------------------------------", textSize);

                                printing.forPrintArabicText("طريق الشحن:", textSize);
                                printing.forPrintArabicText(product_shippingMethod, textSize);





                                layout.measure(canvasLayerOne_main.getWidth(), canvasLayerOne_main.getHeight());
                                layout.layout(0, 0, canvasLayerOne_main.getWidth(), canvasLayerOne_main.getHeight());

                                final Bitmap bitmapLayerOne_print = Bitmap.createBitmap(400, layout.getMeasuredHeight(), Bitmap.Config.RGB_565);
                                Canvas canvasLayerOne_print = new Canvas(bitmapLayerOne_print);
                                canvasLayerOne_print.drawColor(Color.WHITE);
                                layout.draw(canvasLayerOne_print);

                                try {
                                    // ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                                    // bitmapLayerOne_print.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
                                    //  byte[] byteArray = byteArrayOutputStream.toByteArray();


                                    File tempDirectory = new File(System.getProperty("java.io.tmpdir"));
                                    File fileWithAbsolutePath = new File(tempDirectory.getAbsolutePath() + "/testFile.jpg");

                                    FileOutputStream fos2 = new FileOutputStream(fileWithAbsolutePath);
                                    bitmapLayerOne_print.compress(Bitmap.CompressFormat.PNG, 85, fos2);
                                    //fos2.write(byteArray);
                                    //fos2.close();
                                    fos2.flush();
                                    fos2.close();



                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                                File tempDirectory = new File(System.getProperty("java.io.tmpdir"));
                                mHoinPrinter.printImage(tempDirectory.getAbsolutePath() + "/testFile.jpg", true);

                                result.success("print");

                            } else {
                                result.success(taha);
                            }
                        }
                );
    }
}
