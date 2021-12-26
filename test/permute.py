

def permute(nums):
    return [ [n] + p
             for i,n in enumerate(nums)
             for p in permute(nums[:i] + nums[i+1:])] or [[]]

print(permute([1,2,3]))


