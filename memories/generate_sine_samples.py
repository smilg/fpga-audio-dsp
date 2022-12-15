from typing import Iterator
from math import sin, pi, floor

def get_sine_sample(amplitude: float, frequency: float, time: float) -> float:
    '''
    Calculates the value of a sine wave with amplitude A and frequency f (Hz) at time t (sec).

    Args:
        amplitude (float): amplitude of the wave
        frequency (float): frequency of the wave in Hz
        time (float): time in seconds

    Returns:
        float: the value of the specified sine wave
    '''

    return amplitude*sin(2*pi*frequency*time)

def round_half_up(n: float) -> int:
    '''
    Rounds a number to the nearest whole number, with ties (n.5) being rounded up.

    Args:
        n (float): input number

    Returns:
        int: n rounded to the nearest whole number
    '''
    return floor(n + 0.5)

def generate_samples(lengths: list, freqs: list, amps: list, sample_rate: int) -> Iterator[float]:
    '''
    Generates sine wave samples based on a sample rate and intervals of freqencies and amplitudes. 

    Args:
        lengths (list): A list of durations in ms for each segment of the signal
        freqs (list): A list of frequencies in Hz for each segment of the signal
        amps (list): A list of amplitudes for each segment of the signal
        sample_rate (int): The desired sample rate in Hz.

    Yields:
        Iterator[float]: Signed samples of the wave defined by the input arguments
    '''
    current_segment = 0
    sample_index = 0
    num_samples_list = [floor(sample_rate/1000*length) for length in lengths]
    while sample_index < sum(num_samples_list):
        if sample_index >= sum(num_samples_list[:current_segment+1]):
            current_segment += 1
        yield get_sine_sample(amps[current_segment], freqs[current_segment], sample_index/sample_rate)
        sample_index += 1

def sample_to_bytes(sample: float) -> str:
    '''
    Converts a signed audio sample to a 16 bit two's complement hex string.

    Args:
        sample (float): Input sample

    Returns:
        str: The input as a 16 bit two's complement number in hexadecimal form.
    '''
    return round_half_up(sample).to_bytes(2, 'big', signed=True).hex()

if __name__ == "__main__":
    SAMPLE_RATE = 44100

    SAMPLE_FREQUENCY_LENGTHS =  [50, 50, 900]   # ms
    SAMPLE_FREQUENCIES =        [0, 440, 0]  # Hz
    SAMPLE_AMPLITUDES =         [0, 2**13, 0] # out of 32767

    GEN_SAMPLE_ARGS = (SAMPLE_FREQUENCY_LENGTHS, SAMPLE_FREQUENCIES, SAMPLE_AMPLITUDES, SAMPLE_RATE)

    with open('memories/sine_samples_pulse.memh', 'w') as memfile:
        memfile.writelines([sample_to_bytes(sample)+'\n' for sample in generate_samples(*GEN_SAMPLE_ARGS)])
