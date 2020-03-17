package miPhysics.ModelRenderer;

public class MatRenderProps{

    private int m_r;
    private int m_g;
    private int m_b;
    private float m_size;
    private float m_inertia_scaling;

    public MatRenderProps(int r, int g, int b, float size){
        m_r = r;
        m_g = g;
        m_b = b;

        m_size = size;
        m_inertia_scaling = 0;
    }

    public MatRenderProps(int r, int g, int b, float size, float scale){
        this(r,g,b,size);
        m_inertia_scaling = scale;
    }

    public void setInertiaScaling(float val){
        m_inertia_scaling = val;
    }
    public float getInertiaScaling(){return m_inertia_scaling;}

    public int getColor(){
        return m_r << 16 + m_g << 8 + m_b;
    }

    public void setColor(int col){
        m_r = col >> 16 & 0xFF;
        m_g = col >> 16 & 0xFF;
        m_b = col & 0xFF;

    }

    public void setColor(int r, int g, int b){
        m_r = r;
        m_g = g;
        m_b = b;
    }

    public float getBaseSize(){return m_size;}
    public void setBaseSize(float size){m_size = size;}

    public float getScaledSize(double massVal){
        return m_size + m_inertia_scaling*(float)massVal;
    }

    public int red(){return m_r;}
    public int green(){return m_g;}
    public int blue(){return m_b;}
}