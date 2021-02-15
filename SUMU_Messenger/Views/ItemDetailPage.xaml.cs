using SUMU_Messenger.ViewModels;
using System.ComponentModel;
using Xamarin.Forms;

namespace SUMU_Messenger.Views
{
    public partial class ItemDetailPage : ContentPage
    {
        public ItemDetailPage()
        {
            InitializeComponent();
            BindingContext = new ItemDetailViewModel();
        }
    }
}