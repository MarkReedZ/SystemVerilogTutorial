
database -open waves -shm
probe -create tb -depth all -all -memories -functions -tasks -shm -database waves
assertion -summary -final
run
exit

