import torchvision
import torch
import torchvision.transforms as transform
import matplotlib.pyplot as plt

transform = transform.Compose([
    transform.Resize((32, 32)),
    transform.ToTensor(),
    transform.Normalize((0.5,), (0.5,)),
    transform.RandomHorizontalFlip(p=0.5),  
    transform.RandomRotation(10),           
    transform.RandomAffine(degrees=0, translate=(0.1, 0.1)),

])

batch_size = 32

trainset = torchvision.datasets.FashionMNIST(root='D:\Study\CNN\Models\AlexNet', train=True, download= True, transform=transform)
trainloader = torch.utils.data.DataLoader(trainset, batch_size= batch_size, shuffle=True,num_workers=2)

testset = torchvision.datasets.FashionMNIST(root='D:\Study\CNN\Models\AlexNet', train=False, download= False, transform=transform)
testloader = torch.utils.data.DataLoader(testset, batch_size= batch_size, shuffle=False,num_workers=2)

fashion_mnist_labels = [
    'T-shirt/top',
    'Trouser',
    'Pullover',
    'Dress',
    'Coat',
    'Sandal',
    'Shirt',
    'Sneaker',
    'Bag',
    'Ankle boot'
]