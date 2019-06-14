package miPhysics;

public class MidiControler extends AbstractController
{

    int control;

    public MidiControler(PhysicalModel pm_,int ctrl_,float min_,float max_,String name_,String param_ )
    {
        super(pm_,name_,param_);
        control = ctrl_;
        params.put("min",min_);
        params.put("max",max_);


        params.put("vmin",new Float(0));
        params.put("vmax",new Float(127));
        pm_.addParamControler(subsetName + "_" + param,subsetName,param,new Float(1)/pm.getSimRate());
        pm.getParamControler(subsetName + "_" + param).init((params.get("max")-params.get("min"))/2);
    }

    public MidiControler(PhysicalModel pm_,int ctrl_,float min_,float max_,String name_,String param_ ,float rampTime)
    {
        super(pm_,name_,param_);
        control = ctrl_;
        params.put("min",min_);
        params.put("max",max_);


        params.put("vmin",new Float(0));
        params.put("vmax",new Float(127));
        pm_.addParamControler(subsetName + "_" + param,subsetName,param,rampTime);
        pm.getParamControler(subsetName + "_" + param).init((params.get("max")-params.get("min"))/2);
    }




    public void changeParam(int ctrl,int value)
    {
        System.out.println(ctrl + " changed to " + value);
        if(control == ctrl) changeParam(value);
    }

    public void changeParam(int value)
    {
        System.out.println("change to " + value);
        pm.getParamControler(subsetName + "_" + param).triggerRamp(linearScale(value));
    }
}