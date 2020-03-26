package miPhysics.Control;

import miPhysics.Engine.PhysicsContext;

public class MidiController extends AbstractController
{

    int control;

    public MidiController(PhysicsContext pc_, int ctrl_, float min_, float max_, String name_, String param_, float rampTime )
    {
        super(pc_,name_,param_);
        control = ctrl_;
        params.put("min",min_);
        params.put("max",max_);


        params.put("vmin",new Float(0));
        params.put("vmax",new Float(127));
        computeLinearParams();

        pc.addParamController(subsetName + "_" + param,subsetName,param,rampTime);
        pc.getParamController(subsetName + "_" + param).init((params.get("max")+params.get("min"))/2);
    }

    public static MidiController addMidiController(PhysicsContext pc_,int ctrl_,float min_,float max_,String name_,String param_ ,float rampTime)
    {
        return new MidiController(pc_,ctrl_,min_,max_,name_,param_,rampTime);
    }

    public static MidiController addMidiController(PhysicsContext pm_,int ctrl_,float min_,float max_,String name_,String param_ )
    {
        return new MidiController(pm_,ctrl_,min_,max_,name_,param_,new Float(1)/pm_.getSimRate());
    }



    public void changeParam(int ctrl,int value)
    {
        if(control == ctrl) changeParam(value);
    }

    public void changeParam(int value)
    {
        pc.getParamController(subsetName + "_" + param).triggerRamp(linearScale(value));
    }
}
