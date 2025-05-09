const float C = 261.63;
const float D = 293.66;
const float E = 329.63;
const float F = 349.23;
const float G = 392.00;
const float A = 440.00;
const float B = 493.88;
const float C2 = 523.25;

const float[] notes = float[] (C, D, E, F, G, A, B, C2);

vec2 noteFreq(float freq, float time) {
    // 6.2831 = 2pi
    // exp() goes exponentially down to fade out the volume
    return vec2(sin(6.2831 * freq * time) * exp(-3.0 * time));
}

vec2 mainSound( in int samp,float time) {
    vec2 result;
    // time counts in seconds
    // (time - x) is required, because we want to "reset" exp() function
    // otherwise the output of exp() function will go down globally
    // and we'll hear only first note
    for (int note = 0; note < notes.length(); note++) {
        float x = float(note) * 1.0;
        if (time > x) {
            // += is here because we are combining result with
            // the "values" of previous and/or simultaneous notes
            result += noteFreq(notes[note], time - x);
        }
    }
    
    return result;
}