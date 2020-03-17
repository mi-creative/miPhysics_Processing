package miPhysics.Engine.Sound;

import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.ServiceLoader;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jaudiolibs.audioservers.*;
import org.jaudiolibs.audioservers.ext.*;

/*
import org.jaudiolibs.audioservers.AudioClient;
import org.jaudiolibs.audioservers.AudioConfiguration;
import org.jaudiolibs.audioservers.AudioServer;
import org.jaudiolibs.audioservers.AudioServerProvider;
import org.jaudiolibs.audioservers.ext.ClientID;
import org.jaudiolibs.audioservers.ext.Connections;
*/
import miPhysics.Engine.*;

/* Based on SineAudioClient, in the example project of jaudiolibs */
public class miPhyAudioClient implements  AudioClient{

    private final AudioServer server;
    protected long step;
    private PhysicalModel mdl;

    public PhysicalModel getMdl() {
        return mdl;
    }

    //protected String[] listeningPoint;
    //protected int[] listeningPointsInd;
    //private float[] data;

    private List<float[]> buffers;

    //private int idx;
    //private float prevSample;


    private Thread runner;

    /*
    public void setListeningPoint(String[] listeningPoint) {
        this.listeningPoint = listeningPoint;
    }
    public void setListeningPoint(String[] listeningPoint,int[] listeningPointsInd) {
        this.listeningPoint = listeningPoint;
        this.listeningPointsInd = listeningPointsInd;
    }*/

    public static miPhyAudioClient miPhyJack(float sampleRate,int inputChannelCount, int outputChannelCount, PhysicalModel mdl)
    {
        try {
            return new miPhyAudioClient(sampleRate, inputChannelCount, outputChannelCount, mdl, 1024, "JACK");
        }
        catch(Exception e)
        {
            Logger.getLogger(miPhyAudioClient.class.getName()).log(Level.SEVERE, null, "Could not create a jack miPhyAudioClient");
        }
        return null;
    }

    public static miPhyAudioClient miPhyClassic(float sampleRate,int inputChannelCount, int outputChannelCount, PhysicalModel mdl)
    {
        try {
            return new miPhyAudioClient(sampleRate, inputChannelCount, outputChannelCount, mdl, 1024, "JavaSound");
        }
        catch(Exception e)
        {
            Logger.getLogger(miPhyAudioClient.class.getName()).log(Level.SEVERE, null, "Could not create a jack miPhyAudioClient");
        }
        return null;
    }

    public miPhyAudioClient(float sampleRate,int inputChannelCount, int outputChannelCount, PhysicalModel mdl, int bufferSize, String serverType) throws Exception
    {
        AudioServerProvider provider = null;
        for (AudioServerProvider p : ServiceLoader.load(AudioServerProvider.class)) {
            if (serverType.equals(p.getLibraryName())) {
                provider = p;
                break;
            }
        }
        if (provider == null) {
            throw new NullPointerException("No AudioServer found that matches : " + serverType);
        }

        AudioConfiguration config = new AudioConfiguration(
                sampleRate, //sample rate
                inputChannelCount, // input channels
                outputChannelCount, // output channels
                bufferSize, //buffer size
                false);
                // extensions
                //new ClientID("miPhy"),
                //Connections.OUTPUT);
        server = provider.createServer(config, this);

        // Set the physical model from arguments (seems better than forcing to create it in here)
        this.mdl = mdl;
        mdl.setSimRate(44100);

        buffers = new ArrayList<>(outputChannelCount);

        for(int i=0; i< outputChannelCount;i++)
        {
            buffers.add(new float[bufferSize]);
        }
        /* Create a Thread to run our server. All servers require a Thread to run in.
         */
        runner = new Thread(new Runnable() {
            public void run() {
                // The server's run method can throw an Exception so we need to wrap it
                try {
                    server.run();
                } catch (Exception ex) {
                    Logger.getLogger(miPhyAudioClient.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
        });
        // set the Thread priority as high as possible.
        runner.setPriority(Thread.MAX_PRIORITY);
    }

    public void configure(AudioConfiguration context) throws Exception {
        /* Check the configuration of the passed in context, and set up any
         * necessary resources. Throw an Exception if the sample rate, buffer
         * size, etc. cannot be handled. DO NOT assume that the context matches
         * the configuration you passed in to create the server - it will
         * be a best match.
         */

    }
    public boolean process(long time, List<FloatBuffer> inputs, List<FloatBuffer> outputs, int nframes) {

        for(float[] bf:buffers)
        {
            if( bf == null || bf.length != nframes) bf = new float[nframes];
        }
        // always use nframes as the number of samples to process
        //System.out.println("input=" + inputs.get(0).get(0));
        for (int i = 0; i < nframes; i++) {
            int currentChannel=0;

            /*
            for(PositionController pc:mdl.getPositionControllers())
            {
                FloatBuffer input = inputs.get(pc.getInputIndex());
                pc.setValue(input.get(i));
            }
            */

            mdl.computeSingleStep();

            ArrayList<Observer3D> obs = mdl.getObservers();

            for(float[] buff:buffers)
            {

                // Getting model data from observers
                if(currentChannel < obs.size()){
                    if(obs.get(currentChannel) != null){
                        buff[i] = (float)obs.get(currentChannel).observePos().y;
                    }
                    else buff[i] = 0;
                }


                /*
                if (mdl.matExists(listeningPoint[0])) {
                    buff[i] = (float) ((mdl.getMatPosition(listeningPoint[currentChannel]).y));
                }
                else if (mdl.moduleExists(listeningPoint[0])) {
                    buff[i] =(float) ((mdl.getMatPosition(listeningPoint[currentChannel],
                            listeningPointsInd[currentChannel]).y));
                }
                */
                currentChannel++;
            }
        }
        int currentChannel = 0;
        for(FloatBuffer buff:outputs) buff.put(buffers.get(currentChannel++));

        return true;
    }

    public void shutdown() {
        //dispose resources.

    }

    public void start()
    {
        runner.start();
    }

    /*
    public static void main(String[] args) throws Exception {
        miPhyAudioClient simUGen = miPhyAudioClient.miPhyJack(44100.f,1,2);//new miPhyAudioClient(44100.f,0,2,1024,"JACK"); //<>// //<>//

        simUGen.getMdl().setGravity(0);
        simUGen.getMdl().setFriction(0);

        simUGen.getMdl().addMass3D("percMass", 100, new Vect3D(0, -4, 0.), new Vect3D(0, 2, 0.));

        simUGen.getMdl().addString2D("string");

        simUGen.getMdl().addMContact2D("perc","percMass","string");

        String[] listeningPoints = new String[2];
        listeningPoints[0] = "string";
        int[] listeningPointsInd = new int[2];
        listeningPointsInd[0] = 3;
        listeningPoints[1] ="string";
        listeningPointsInd[1]= 2;
        simUGen.getMdl().addPositionController("osc_perc",0,"percMass",0,new Vect3D(0,10,0),new Vect3D(0,0,0));
        simUGen.setListeningPoint(listeningPoints,listeningPointsInd);

        simUGen.getMdl().init();

        simUGen.start();


    }*/
}
