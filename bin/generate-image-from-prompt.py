import argparse
import redis
import torch
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler

print("In Pythonland")
parser = argparse.ArgumentParser()
parser.add_argument("prompt_id", type=str, help="The id of the prompt to retrieve.")
args = parser.parse_args()

# Read prompt from Redis
print("Reading prompt from Redis...")
r = redis.Redis(host='localhost', port=6379, db=0)
prompt = str(r.get(args.prompt_id))
print("Generating image for prompt:\n", prompt)

# Use the DPMSolverMultistepScheduler (DPM-Solver++) scheduler here instead
#model_id = "stabilityai/stable-diffusion-2-1"
model_id = "CompVis/stable-diffusion-v1-4"
pipe = StableDiffusionPipeline.from_pretrained(model_id, torch_dtype=torch.float16)
#pipe.scheduler = DPMSolverMultistepScheduler.from_config(pipe.scheduler.config)
pipe.enable_attention_slicing()
pipe = pipe.to("cuda")

image = pipe(prompt).images[0]
image.save("generated/" + args.prompt_id + '.png')
