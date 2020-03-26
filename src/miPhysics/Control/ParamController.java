package miPhysics.Control;

import miPhysics.Engine.PhysicsContext;

public class ParamController extends AbstractController
{

    long step=0;
    float previous_value;
    boolean inRamp = false;
    //Vect3D center;

    public ParamController(PhysicsContext pc_, float rampTime, String name, String param_ ) {
        super(pc_,name,param_);
      params.put("rampTime",rampTime);
      params.put("vmin",new Float(0));
      params.put("vmax",rampTime*pc.getSimRate());
    }


    public void updateParams()
    {
        if(inRamp) {
            step++;
            if (step <= params.get("vmax")) {
                //System.out.println("change  param " + param + " of subset " + subsetName + " with value " + linearScale(step));

                // I don't understand the specific role for distX here... not very generic
                //if (param.equals("distX")) pm.changeDistXBetweenSubset(center, linearScale(step), subsetName);
                //else pm.changeParamOfSubset(linearScale(step), subsetName, param);
            }
            else inRamp = false;
        }
    }

    public void triggerRamp(float value)
    {
        params.put("min",previous_value);
        params.put("max",value);
        params.put("vmax",params.get("rampTime")*pc.getSimRate());//in case it changed
        computeLinearParams();
        //System.out.println("trigger ramp for " + params.get("rampTime")*pm.getSimRate() + " steps from " + previous_value + " to " + value + " a=" + a + " b="+b);
        inRamp = true;
        step = 0;
        previous_value = value;
    }

    public void init(float value)
    {
        previous_value = value;
        params.put("min",value);
        params.put("max",value);
        computeLinearParams();

        // I don't really understand why we're making a special case for distX...

//        if(param.equals("distX"))
//        {
//          center = pm.getBarycenterOfSubset(subsetName);
//            System.out.println("controller distX init with center " + center.toString());
//          pm.changeDistXBetweenSubset(center,value,subsetName);
//        }
//        else pm.changeParamOfSubset(value,subsetName,param);

        System.out.println("controller for param " + param + " of subset " + subsetName + " initialized with value " + value);
    }
}

