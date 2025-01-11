import os
import subprocess
from pathlib import Path
import argparse
import sys
import multiprocessing
from concurrent.futures import ProcessPoolExecutor
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def convert_file(aud_file: str, mp3_file: str) -> bool:
    """
    Convert a single .aud file to .mp3 format

    Args:
        aud_file: Path to input .aud file
        mp3_file: Path to output .mp3 file

    Returns:
        bool: True if conversion successful, False otherwise
    """
    pcm_path = aud_file + '.pcm'

    try:
        # Step 1: Convert .aud to .pcm using silk decoder
        logging.info(f"Converting {aud_file} to PCM...")
        decoder_result = subprocess.run(
            ['./silk/decoder', aud_file, pcm_path],
            check=True,
            capture_output=True,
            text=True
        )

        # Verify PCM file was created successfully
        if not os.path.exists(pcm_path):
            logging.error(f"Error: PCM file {pcm_path} was not created")
            return False

        # Step 2: Convert .pcm to .mp3 using ffmpeg
        logging.info(f"Converting {pcm_path} to MP3...")
        ffmpeg_result = subprocess.run([
            'ffmpeg',
            '-y',  # Overwrite output file if it exists
            '-f', 's16le',
            '-ar', '24000',
            '-ac', '1',
            '-i', pcm_path,
            mp3_file
        ], check=True, capture_output=True, text=True)

        # Step 3: Remove the intermediate .pcm file
        os.remove(pcm_path)
        logging.info(f"Successfully converted {aud_file} to {mp3_file}")
        return True

    except subprocess.CalledProcessError as e:
        logging.error(f"Error converting {aud_file}: {e}")
        if os.path.exists(pcm_path):
            os.remove(pcm_path)
        return False
    except Exception as e:
        logging.error(f"Unexpected error processing {aud_file}: {e}")
        if os.path.exists(pcm_path):
            os.remove(pcm_path)
        return False

def process_task(task):
    return convert_file(*task)

def convert_aud_to_mp3(input_dir: str, output_dir: str):
    # Get all .aud files in the directory
    aud_files = list(Path(input_dir).glob('*.aud'))  # Convert to list to get total count

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    total_count = len(aud_files)
    success_count = 0

    # Prepare conversion tasks
    conversion_tasks = []
    for aud_file in aud_files:
        aud_path = str(aud_file)
        mp3_filename = aud_file.name.replace('.aud', '.mp3')
        mp3_path = str(Path(output_dir) / mp3_filename)
        conversion_tasks.append((aud_path, mp3_path))

    # Use ProcessPoolExecutor for parallel processing
    max_workers = multiprocessing.cpu_count()  # Use number of CPU cores
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(process_task, conversion_tasks))
        success_count = sum(1 for result in results if result)

    if total_count > 0:
        logging.info(f"\nConversion complete: {success_count}/{total_count} files converted successfully")

if __name__ == "__main__":
    # Set up logging configuration
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    parser = argparse.ArgumentParser(description='Convert .aud files to .mp3 format')
    parser.add_argument('input_dir', help='Directory containing .aud files')
    parser.add_argument('output_dir', help='Directory for output .mp3 files')

    args = parser.parse_args()

    if not os.path.isdir(args.input_dir):
        logging.error(f"Error: {args.input_dir} is not a valid directory")
        sys.exit(1)

    convert_aud_to_mp3(args.input_dir, args.output_dir)
