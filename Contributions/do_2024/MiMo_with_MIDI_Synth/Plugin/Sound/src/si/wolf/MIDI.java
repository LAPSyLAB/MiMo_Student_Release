package si.wolf;

import javax.sound.midi.*;
import java.awt.Color;
import java.awt.Graphics;
import java.util.Arrays;

import com.cburch.logisim.data.Attribute;
import com.cburch.logisim.data.AttributeOption;
import com.cburch.logisim.data.AttributeSet;
import com.cburch.logisim.data.Attributes;
import com.cburch.logisim.data.Bounds;
import com.cburch.logisim.data.Direction;
import com.cburch.logisim.data.Value;
import com.cburch.logisim.data.BitWidth;
import com.cburch.logisim.instance.Instance;
import com.cburch.logisim.instance.InstanceData;
import com.cburch.logisim.instance.InstanceFactory;
import com.cburch.logisim.instance.InstancePainter;
import com.cburch.logisim.instance.InstanceState;
import com.cburch.logisim.instance.Port;
import com.cburch.logisim.instance.StdAttr;
import com.cburch.logisim.std.wiring.DurationAttribute;
import com.cburch.logisim.util.GraphicsUtil;

import com.cburch.logisim.util.StringUtil;
import com.cburch.logisim.util.LocaleManager;
import com.cburch.logisim.util.StringGetter;

public class MIDI extends InstanceFactory{
	
	private static final BitWidth BIT_WIDTH = BitWidth.create(4);
	
	public MIDI(){
		super("Speaker");
		setAttributes(new Attribute[] { StdAttr.WIDTH },
                new Object[] { BitWidth.create(7) });
		setOffsetBounds(Bounds.create(-30, -30, 30, 60));
		Port[] ports = new Port[3];

		ports[0] = new Port(-30, 0, Port.INPUT, StdAttr.WIDTH); //Note port
		ports[1] = new Port(-30, 10, Port.INPUT, StdAttr.WIDTH); //Note velocity port
		ports[2] = new Port(-30, -10, Port.INPUT, 1); //Reset port

		ports[2].setToolTip(new StringGetter2("Reset"));
		ports[0].setToolTip(new StringGetter2("Note"));
		ports[1].setToolTip(new StringGetter2("Note Velocity"));

		setPorts(ports);
		setIconName("speaker.gif");
	}
	
	@Override
	public void propagate(InstanceState state) {
		int note = 0; 		//7 bit in
		int velocity = 0; 	//7 bit in
		Value valnote = state.getPort(0);
		Value valvelocity = state.getPort(1);
		Value valonoff = state.getPort(2);
		note = valnote.toIntValue();
		velocity = valvelocity.toIntValue();
		
		play(note,velocity,valonoff.toIntValue());
	}
	
	public void paintInstance(InstancePainter painter) {
        painter.drawBounds();
        painter.drawPort(0); // draw a triangle on port 0
        painter.drawPort(1); // draw port 1 as just a dot
		painter.drawPort(2);
        
        // Display the current counter value centered within the rectangle.
        // However, if the context says not to show state (as when generating
        // printer output), then skip this.
        if(painter.getShowState()) {
            Bounds bds = painter.getBounds();
        }
    }

    public void play(int note,int velocity,int flag) { 
      try{
		int volume = 127;
		
		Synthesizer midiSynth;
		Instrument[] instr;
		MidiChannel[] mChannels;
		
		midiSynth = MidiSystem.getSynthesizer(); 
        midiSynth.open();

        //get and load default instrument and channel lists
        instr = midiSynth.getDefaultSoundbank().getInstruments();
        mChannels = midiSynth.getChannels();
		
		if (flag==1)
		{
			mChannels[0].allNotesOff();
		}

        midiSynth.loadInstrument(instr[0]);//load an instrument

        mChannels[0].noteOn(note,velocity);//On channel 0, play note number 60 with velocity 100
		mChannels[0].controlChange(7,volume);

      } catch (MidiUnavailableException e) {}
   }

}    