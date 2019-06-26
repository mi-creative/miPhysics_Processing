package miPhysics;

public class MidiControler extends AbstractController
{

    int control;

    public MidiControler(PhysicalModel pm_,int ctrl_,float min_,float max_,String name_,String param_,float rampTime )
    {
        super(pm_,name_,param_);
        control = ctrl_;
        params.put("min",min_);
        params.put("max",max_);


        params.put("vmin",new Float(0));
        params.put("vmax",new Float(127));
        computeLinearParams();

        pm.addParamControler(subsetName + "_" + param,subsetName,param,rampTime);
        pm.getParamControler(subsetName + "_" + param).init((params.get("max")+params.get("min"))/2);
    }

    public static MidiControler addMidiControler(PhysicalModel pm_,int ctrl_,float min_,float max_,String name_,String param_ ,float rampTime)
    {
        return new MidiControler(pm_,ctrl_,min_,max_,name_,param_,rampTime);
    }

    public static MidiControler addMidiControler(PhysicalModel pm_,int ctrl_,float min_,float max_,String name_,String param_ )
    {
        return new MidiControler(pm_,ctrl_,min_,max_,name_,param_,new Float(1)/pm_.getSimRate());
    }



    public void changeParam(int ctrl,int value)
    {
        if(control == ctrl) changeParam(value);
    }

    public void changeParam(int value)
    {
        pm.getParamControler(subsetName + "_" + param).triggerRamp(linearScale(value));
    }
}